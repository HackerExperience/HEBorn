module OS.Header.ConnectionBarView exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (disabled)
import Html.CssHelpers
import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Utils.Html.Events exposing (onClickMe, onClickWithStopProp)
import Utils.Html.Attributes exposing (boolAttr)
import Game.Account.Bounces.Models as Bounces
import Game.Account.Bounces.Shared as Bounces
import Game.Meta.Types.Context exposing (Context(..))
import Game.Meta.Types.Network as Network
import Game.Servers.Shared as Servers
import OS.Header.Config exposing (..)
import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import OS.Header.Resources exposing (..)
import UI.Layouts.VerticalList exposing (..)
import UI.Elements.CustomSelect exposing (customSelect)
import Apps.Params as AppParams exposing (AppParams)
import Apps.BounceManager.Shared as BounceManager


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view ({ toMsg } as config) ({ openMenu } as model) =
    let
        bounces =
            config.bounces

        activeGatewayCId =
            config.activeGatewayCId

        activeBounce =
            config.activeBounce

        activeEndpointCId =
            config.activeEndpointCId

        endpoints =
            config.endpoints
                |> List.map Just
                |> (::) Nothing

        gatewayBounces =
            case activeEndpointCId of
                Nothing ->
                    bounces
                        |> Dict.keys
                        |> List.map Just
                        |> (::) Nothing

                Just _ ->
                    []

        onGateway =
            config.activeContext
                |> (==) Gateway
    in
        div
            [ class [ Connection ] ]
            [ contextToggler onGateway (toMsg <| ContextTo Gateway) activeEndpointCId
            , gatewaySelector config openMenu activeGatewayCId config.gateways
            , bounceSelector config activeBounce activeEndpointCId model
            , bounceMenu config activeBounce activeEndpointCId model
            , endpointSelector config openMenu activeEndpointCId endpoints
            , contextToggler (not onGateway) (toMsg <| ContextTo Endpoint) activeEndpointCId
            ]



-- INTERNALS


contextToggler : Bool -> msg -> Maybe Servers.CId -> Html msg
contextToggler active handler activeEndpointCId =
    let
        classes =
            if active then
                [ Context, Selected ]
            else
                [ Context ]
    in
        case activeEndpointCId of
            Just cid ->
                span
                    [ onClick handler
                    , class classes
                    , boolAttr headerContextActiveAttrTag active
                    ]
                    []

            Nothing ->
                text ""


selector :
    Config msg
    -> List Class
    -> (Maybe a -> msg)
    -> OpenMenu
    -> (a -> Maybe (Html msg))
    -> OpenMenu
    -> Maybe a
    -> List (Maybe a)
    -> Html msg
selector { toMsg } classes wrapper kind render open active list =
    let
        render_ _ item =
            case item of
                Just item ->
                    render item

                Nothing ->
                    Just (text "None")

        handler =
            (toMsg <| ToggleMenus kind)
    in
        customSelect
            [ class classes ]
            ( toMsg MouseEnterDropdown, toMsg MouseLeavesDropdown )
            wrapper
            handler
            render_
            (open == kind)
            active
            list



-- GATEWAY


gatewaySelector :
    Config msg
    -> OpenMenu
    -> Servers.CId
    -> List Servers.CId
    -> Html msg
gatewaySelector ({ toMsg } as config) open cid list =
    let
        render_ _ =
            config.getLabel >> Maybe.map text

        msg cid =
            config.batchMsg
                [ config.onSetGateway cid
                , toMsg DropMenu
                ]

        openMsg =
            (toMsg <| ToggleMenus GatewayOpen)
    in
        customSelect
            [ class [ SGateway ] ]
            ( toMsg MouseEnterDropdown, toMsg MouseLeavesDropdown )
            msg
            openMsg
            render_
            (open == GatewayOpen)
            cid
            list



-- ENDPOINT


endpointSelector :
    Config msg
    -> OpenMenu
    -> Maybe Servers.CId
    -> List (Maybe Servers.CId)
    -> Html msg
endpointSelector ({ toMsg } as config) =
    let
        render =
            config.getLabel >> Maybe.map text

        msg cid =
            config.batchMsg
                [ config.onSetEndpoint cid
                , toMsg DropMenu
                ]
    in
        selector config [ SEndpoint ] msg EndpointOpen render



-- BOUNCES


bounceSelector :
    Config msg
    -> Maybe String
    -> Maybe Servers.CId
    -> Model
    -> Html msg
bounceSelector config activeBounce activeEndpointCId model =
    let
        name =
            activeBounce
                |> Maybe.andThen (flip Bounces.getName config.bounces)
                |> Maybe.withDefault "None"

        attrs =
            [ class [ SBounce ]
            , ToggleMenus (BounceOpen activeBounce)
                |> config.toMsg
                |> onClickMe
            , MouseEnterDropdown
                |> config.toMsg
                |> onMouseEnter
            , MouseLeavesDropdown
                |> config.toMsg
                |> onMouseLeave
            ]
    in
        div attrs
            [ text name ]


bounceMenu :
    Config msg
    -> Maybe String
    -> Maybe Servers.CId
    -> Model
    -> Html msg
bounceMenu config activeBounce activeEndpointCId model =
    let
        class_ =
            case model.openMenu of
                BounceOpen _ ->
                    class [ BounceMenu, Selected ]

                _ ->
                    class [ BounceMenu ]

        readonlyMode =
            activeEndpointCId
                |> (/=) Nothing

        attrs =
            [ class_
            , MouseEnterDropdown
                |> config.toMsg
                |> onMouseEnter
            , MouseLeavesDropdown
                |> config.toMsg
                |> onMouseLeave
            ]
    in
        div attrs
            [ bouncePicker config readonlyMode
            , bounceView config readonlyMode activeBounce model
            ]


bouncePicker : Config msg -> Bool -> Html msg
bouncePicker ({ toMsg, batchMsg, onSetBounce } as config) readonly =
    let
        noBounceAttr =
            [ onSetBounce Nothing, toMsg <| DropMenu ]
                |> batchMsg
                |> onClick
                |> flip (::) [ disabled readonly ]

        hidden list =
            if readonly then
                Hidden :: list
            else
                list
    in
        div [ class (hidden [ BounceMenuLeft ]) ]
            [ bounceList config
            , div []
                [ button
                    noBounceAttr
                    [ text "No Bounce" ]
                ]
            ]


bounceList : Config msg -> Html msg
bounceList ({ bounces } as config) =
    bounces
        |> Dict.foldl (bounceListEntry config) []
        |> verticalList [ class [ BounceList ] ]


bounceListEntry :
    Config msg
    -> Bounces.ID
    -> Bounces.Bounce
    -> List (Html msg)
    -> List (Html msg)
bounceListEntry ({ toMsg, bounces } as config) bounceId bounce acc =
    let
        name =
            Bounces.getName bounceId bounces
                |> Maybe.map (text)
                |> Maybe.withDefault (text "")

        msg =
            [ toMsg <| SelectBounce (Just bounceId) ]
                |> config.batchMsg
                |> onClickMe
    in
        div
            [ class [ BounceListEntry ], msg ]
            [ name ]
            |> flip (::) acc


bounceView : Config msg -> Bool -> Maybe String -> Model -> Html msg
bounceView config readonly activeBounce model =
    let
        selectedBounce =
            case model.openMenu of
                BounceOpen maybeBounce ->
                    maybeBounce

                _ ->
                    Nothing

        readOnly list =
            if readonly then
                ReadOnly :: list
            else
                list
    in
        div [ class <| readOnly [ BounceMenuRight ] ]
            [ bounceMembers config readonly selectedBounce
            , bounceOptions config readonly activeBounce model
            ]


bounceMembers : Config msg -> Bool -> Maybe String -> Html msg
bounceMembers ({ bounces } as config) readonly selectedBounce =
    let
        path =
            selectedBounce
                |> Maybe.andThen (flip Bounces.getPath bounces)
                |> Maybe.withDefault []

        readOnly list =
            if readonly then
                ReadOnly :: list
            else
                list
    in
        if List.isEmpty path then
            div [ class <| readOnly [ BounceMembers, Empty ] ] [ text "No Bounce" ]
        else
            path
                |> List.foldr (bounceMember config) ( [], List.length path )
                |> Tuple.first
                |> div [ class <| readOnly [ BounceMembers ] ]


bounceMember :
    Config msg
    -> Network.NIP
    -> ( List (Html msg), Int )
    -> ( List (Html msg), Int )
bounceMember config nip ( acc, counter ) =
    let
        batchMsg =
            onClick <| config.batchMsg []
    in
        div [ class [ BounceMember ] ]
            [ button [ batchMsg ] [ text <| toString (counter) ]
            , text "═>"
            , br [] []
            , text <| Network.toString nip
            ]
            |> flip (::) acc
            |> flip (,) (counter - 1)


bounceOptions : Config msg -> Bool -> Maybe String -> Model -> Html msg
bounceOptions config readonly activeBounce model =
    let
        inUse =
            case model.openMenu of
                BounceOpen maybeBounce ->
                    (maybeBounce == activeBounce)

                _ ->
                    False

        editMsg bounceId =
            bounceId
                |> BounceManager.WithBounce
                |> AppParams.BounceManager
                |> flip (config.onOpenApp) config.activeGatewayCId
                |> onClick
                |> List.singleton

        selectMsg bounceId =
            [ config.onSetBounce <| Just bounceId, config.toMsg DropMenu ]
                |> config.batchMsg
                |> onClick
                |> flip (::) [ disabled readonly ]

        btns =
            case model.openMenu of
                BounceOpen bounceId ->
                    case bounceId of
                        Just id ->
                            if inUse then
                                []
                            else
                                [ button (editMsg id) [ text "Edit" ]
                                , button (selectMsg id) [ text "Select" ]
                                ]

                        Nothing ->
                            []

                _ ->
                    []

        hidden list =
            if readonly then
                Hidden :: list
            else
                list
    in
        div [ class (hidden [ BounceOptions ]) ]
            btns
