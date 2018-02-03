module OS.Header.ConnectionBarView exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (disabled)
import Html.CssHelpers
import Utils.Html.Events exposing (onClickMe, onClickWithStopProp)
import Html.Events exposing (onClick)
import Utils.Html.Attributes exposing (boolAttr)
import Game.Account.Bounces.Models as Bounces
import Game.Account.Bounces.Shared as Bounces
import Game.Meta.Types.Context exposing (Context(..))
import Game.Meta.Types.Network as Network
import Game.Servers.Models as Servers exposing (Servers)
import Game.Servers.Shared as Servers
import OS.Header.Config exposing (..)
import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import OS.Resources exposing (..)
import UI.Layouts.VerticalList exposing (..)
import UI.Widgets.CustomSelect exposing (customSelect, bounceSelect)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view ({ toMsg } as config) ({ openMenu } as model) =
    let
        servers =
            config.servers

        bounces =
            config.bounces

        activeGatewayCId =
            config.activeGateway
                |> Tuple.first

        activeBounce =
            config.activeBounce

        activeEndpointCId =
            config.activeEndpointCid

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
            [ class [ Connection ]
            , onClickMe <| toMsg DropMenu
            ]
            [ contextToggler onGateway (toMsg <| ContextTo Gateway) activeEndpointCId
            , gatewaySelector config servers openMenu activeGatewayCId config.gateways model
            , bounceSelector config activeBounce activeEndpointCId model
            , bounceMenu config activeBounce activeEndpointCId model
            , endpointSelector config servers openMenu activeEndpointCId endpoints model
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
    -> Model
    -> Html msg
selector { toMsg, batchMsg } classes wrapper kind render open active list model =
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
    -> Servers.Model
    -> OpenMenu
    -> Servers.CId
    -> List Servers.CId
    -> Model
    -> Html msg
gatewaySelector { toMsg, batchMsg, onSetGateway } servers open cid list model =
    let
        render_ _ cid =
            servers
                |> Servers.get cid
                |> Maybe.map gatewayLabel

        msg cid =
            batchMsg
                [ onSetGateway cid
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


gatewayLabel : Servers.Server -> Html msg
gatewayLabel server =
    server
        |> Servers.getName
        |> text



-- ENDPOINT


endpointSelector :
    Config msg
    -> Servers.Model
    -> OpenMenu
    -> Maybe Servers.CId
    -> List (Maybe Servers.CId)
    -> Model
    -> Html msg
endpointSelector ({ toMsg, onSetEndpoint, batchMsg } as config) servers =
    let
        view cid =
            servers
                |> Servers.get cid
                |> Maybe.map (endpointLabel servers cid)

        msg cid =
            batchMsg
                [ onSetEndpoint cid
                , toMsg DropMenu
                ]
    in
        selector config [ SEndpoint ] msg EndpointOpen view


endpointLabel :
    Servers.Model
    -> Servers.CId
    -> Servers.Server
    -> Html msg
endpointLabel servers cid server =
    let
        ip =
            server
                |> Servers.getActiveNIP
                |> Network.getIp

        name =
            Servers.getName server
    in
        name
            ++ " ("
            ++ ip
            ++ ")"
            |> text



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
            case activeBounce of
                Just bounceId ->
                    case (Bounces.getName bounceId config.bounces) of
                        Just name ->
                            name

                        Nothing ->
                            "None"

                Nothing ->
                    "None"

        msg =
            ToggleMenus BounceOpen
                |> config.toMsg
                |> onClickMe
    in
        div
            (msg :: [ class [ SBounce ] ])
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
                BounceOpen ->
                    class [ BounceMenu, Selected ]

                _ ->
                    class [ BounceMenu ]

        readonlyMode =
            activeEndpointCId
                |> (/=) Nothing
    in
        div [ class_ ]
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
        |> Dict.foldl (bounceListEntry config) ( [], 0 )
        |> Tuple.first
        |> verticalList [ class [ BounceList ] ]


bounceListEntry :
    Config msg
    -> Bounces.ID
    -> Bounces.Bounce
    -> ( List (Html msg), Int )
    -> ( List (Html msg), Int )
bounceListEntry ({ toMsg, bounces } as config) bounceId bounce ( acc, counter ) =
    let
        name =
            case (Bounces.getName bounceId bounces) of
                Just name ->
                    text name

                Nothing ->
                    text ""

        msg =
            [ toMsg <| SelectBounce (Just bounceId) ]
                |> config.batchMsg
                |> onClickMe
    in
        div
            [ class [ BounceListEntry ], msg ]
            [ name ]
            |> flip (::) acc
            |> flip (,) (counter + 1)


bounceView : Config msg -> Bool -> Maybe String -> Model -> Html msg
bounceView config readonly activeBounce ({ selectedBounce } as model) =
    let
        readOnly list =
            if readonly then
                list ++ [ ReadOnly ]
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
            case selectedBounce of
                Just bounceId ->
                    Maybe.withDefault [] (Bounces.getPath bounceId bounces)

                Nothing ->
                    []

        readOnly list =
            if readonly then
                list ++ [ ReadOnly ]
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
            (model.selectedBounce == activeBounce)

        editMsg bounceId =
            onClick <|
                config.batchMsg []

        selectMsg bounceId =
            [ config.onSetBounce <| Just bounceId, config.toMsg DropMenu ]
                |> config.batchMsg
                |> onClick
                |> flip (::) [ disabled readonly ]

        btns =
            case model.selectedBounce of
                Just bounceId ->
                    if inUse then
                        [ text "" ]
                    else
                        [ button [ editMsg bounceId ] [ text "Edit" ]
                        , button (selectMsg bounceId) [ text "Select" ]
                        ]

                Nothing ->
                    [ text "" ]

        hidden list =
            if readonly then
                Hidden :: list
            else
                list
    in
        div [ class (hidden [ BounceOptions ]) ]
            btns
