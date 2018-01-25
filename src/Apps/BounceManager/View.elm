module Apps.BounceManager.View exposing (view)

import Dict
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (..)
import Html.CssHelpers
import Game.Account.Database.Models as Database exposing (HackedServers)
import Game.Account.Bounces.Models as Bounces exposing (Bounce)
import Game.Account.Bounces.Shared as Bounces
import Game.Meta.Types.Network as Network
import UI.Layouts.FlexColumns exposing (flexCols)
import UI.Layouts.VerticalSticked exposing (verticalSticked)
import UI.Layouts.VerticalList exposing (..)
import UI.Widgets.HorizontalTabs exposing (hzTabs)
import Apps.BounceManager.Config exposing (..)
import Apps.BounceManager.Messages exposing (..)
import Apps.BounceManager.Models exposing (..)
import Apps.BounceManager.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view config ({ selected } as model) =
    let
        viewData =
            case selected of
                TabManage ->
                    lazy viewTabManage config

                TabBuild bounceInfo ->
                    lazy3 viewTabBuild config bounceInfo model

        tabs_ =
            tabs model.selectedBounce

        viewTabs =
            hzTabs (compareTabs selected) viewTabLabel (GoTab >> config.toMsg) tabs_
    in
        verticalSticked (Just [ viewTabs ]) [ viewData ] Nothing


tabs : Maybe ( Maybe Bounces.ID, Bounce ) -> List MainTab
tabs selectedBounce =
    case selectedBounce of
        Just bounce ->
            [ TabManage, TabBuild bounce ]

        Nothing ->
            [ TabManage ]


compareTabs : MainTab -> MainTab -> Bool
compareTabs =
    (==)


viewTabLabel : Bool -> MainTab -> ( List (Attribute msg), List (Html msg) )
viewTabLabel _ tab =
    tab
        |> tabToString
        |> text
        |> List.singleton
        |> (,) []


viewTabManage : Config msg -> Html msg
viewTabManage { toMsg, bounces } =
    if Dict.isEmpty bounces then
        div [ class [ Super, Manage, Empty ] ]
            [ button
                [ class [ MiddleButton ]
                , ( Nothing, Bounces.emptyBounce )
                    |> TabBuild
                    |> GoTab
                    |> toMsg
                    |> onClick
                ]
                [ text "Click here to create a new bounce" ]
            ]
    else
        bounces
            |> Dict.toList
            |> List.map viewBounce
            |> verticalList
            |> List.singleton
            |> div [ class [ Super ] ]


viewTabBuild :
    Config msg
    -> ( Maybe Bounces.ID, Bounce )
    -> Model
    -> Html msg
viewTabBuild ({ database, bounces } as config) ( id, bounce ) model =
    let
        path =
            case id of
                Just id ->
                    Maybe.withDefault [] (Bounces.getPath id bounces)

                Nothing ->
                    model.path

        name_ =
            renderName
                config
                model.editing
                model.selectedBounce
                model.bounceNameBuffer
                |> flip (::) (renderNameButtons config model.editing)
    in
        div [ class [ Super, Builder ] ]
            [ div [ class [ Name ] ]
                name_
            , div [ class [ Building ] ]
                [ renderAvailableServers config path model
                , renderBounceBuilder config path model
                ]
            , div [ class [ Buttons ] ]
                [ button [] [ text "Reset" ]
                , button [] [ text "Save" ]
                ]
            ]


renderAvailableServers :
    Config msg
    -> List Network.NIP
    -> Model
    -> Html msg
renderAvailableServers ({ database } as config) path model =
    (Database.getHackedServers database)
        |> Dict.filter (\k v -> not <| List.member k path)
        |> Dict.toList
        |> List.foldl (renderAvailableServer config model) ( [], 0 )
        |> Tuple.first
        |> verticalListWithAttr [ class [ ServerList ] ]
        |> List.singleton
        |> div [ class [ Servers ] ]


renderBounceBuilder :
    Config msg
    -> List Network.NIP
    -> Model
    -> Html msg
renderBounceBuilder config path model =
    div [ class [ Build ] ] (renderEntries config path model)


renderAvailableServer :
    Config msg
    -> Model
    -> ( Network.NIP, Database.HackedServer )
    -> ( List (Html msg), Int )
    -> ( List (Html msg), Int )
renderAvailableServer { toMsg } model ( nip, server ) ( acc, c ) =
    let
        label =
            server.label
                |> Maybe.withDefault (Network.render nip)
                |> \label -> text <| "Label: " ++ label

        ip =
            text <| "IP: " ++ (Network.render nip)

        attr =
            case model.selection of
                Just (SelectingServer nip_) ->
                    if (nip == nip_) then
                        [ class [ HackedServer, Selected ], message ]
                    else
                        [ class [ HackedServer ], message ]

                Just (SelectingSlot num) ->
                    [ class [ HackedServer ], message ]

                Just (SelectingEntry num) ->
                    [ class [ HackedServer ], message ]

                Nothing ->
                    [ class [ HackedServer ], message ]

        message =
            if List.isEmpty model.path then
                ServerAdd nip c
                    |> toMsg
                    |> onClick
            else
                SelectServer nip
                    |> toMsg
                    |> onClick

        servers =
            div attr [ label, br [] [], ip ]
    in
        ( servers :: acc, c + 1 )


renderEntries :
    Config msg
    -> List Network.NIP
    -> Model
    -> List (Html msg)
renderEntries ({ database } as config) nips model =
    let
        hackedServers =
            Database.getHackedServers database
    in
        nips
            |> List.foldr (renderEntry config hackedServers model) ( [], 0 )
            |> Tuple.first
            |> ul [ class [ BounceMap ] ]
            |> List.singleton


renderEntry :
    Config msg
    -> Database.HackedServers
    -> Model
    -> Network.NIP
    -> ( List (Html msg), Int )
    -> ( List (Html msg), Int )
renderEntry config hackedServers model nip ( acc, c ) =
    let
        acu =
            acc
                |> (++) (slot config c model)
                |> (++) (entry config hackedServers nip c model)
    in
        ( acu, c + 1 )


slot : Config msg -> Int -> Model -> List (Html msg)
slot { toMsg } c model =
    let
        selected condition =
            if condition then
                [ Selected ]
            else
                []

        select =
            SelectSlot c
                |> toMsg
                |> onClick

        classes condition =
            (class <| (++) [ Slot ] (selected condition))

        bounceSlot condition =
            [ div [ classes condition, select ] []
            , br [] []
            ]
    in
        case model.selection of
            Just (SelectingSlot num) ->
                bounceSlot (num == c)

            Just (SelectingEntry num) ->
                bounceSlot False

            Just (SelectingServer num) ->
                bounceSlot False

            Nothing ->
                bounceSlot False


entry :
    Config msg
    -> Database.HackedServers
    -> Network.NIP
    -> Int
    -> Model
    -> List (Html msg)
entry { toMsg } hackedServers nip c model =
    let
        server =
            Database.getHackedServer nip hackedServers

        label_ =
            Maybe.withDefault (Network.render nip) server.label |> text

        select =
            SelectEntry c
                |> toMsg
                |> onClick

        selected condition =
            if condition then
                [ Selected ]
            else
                []

        classes condition =
            class ([ BounceNode ] ++ (selected condition))

        bounceNode condition =
            [ span [ classes condition, select ] [ text "● " ]
            , span [] [ label_ ]
            ]
    in
        case model.selection of
            Just (SelectingEntry num) ->
                bounceNode (num == c)

            Just (SelectingSlot num) ->
                bounceNode False

            Just (SelectingServer num) ->
                bounceNode False

            Nothing ->
                bounceNode False


renderMoveMenu : Config msg -> Model -> Html msg
renderMoveMenu config model =
    div [ class [ MoveMenu ] ]
        [ button [ value "/\\" ] []
        , button [ value "\\/" ] []
        , button [ value "X" ] []
        ]


viewBouncePath : List Network.NIP -> Html msg
viewBouncePath ips =
    ips
        |> List.map (Tuple.second >> text)
        |> List.intersperse (text " > ")
        |> span []


viewBounce : ( Bounces.ID, Bounce ) -> Html msg
viewBounce ( id, val ) =
    div [ class [ BounceEntry ] ]
        [ text "ID: "
        , text (toString id)
        , br [] []
        , text "Name: "
        , text val.name
        , br [] []
        , text "Path: "
        , viewBouncePath val.path
        ]


renderEditing : Config msg -> String -> Html msg
renderEditing { toMsg } src =
    input
        [ class [ BoxifyMe ]
        , value src
        , onInput (UpdateEditing >> toMsg)
        ]
        []


renderName :
    Config msg
    -> Bool
    -> Maybe ( Maybe Bounces.ID, Bounce )
    -> Maybe String
    -> Html msg
renderName config editing bounceInfo bounceNameBuffer =
    case bounceInfo of
        Just ( _, bounce ) ->
            if editing then
                case bounceNameBuffer of
                    Just newName ->
                        renderEditing config newName

                    Nothing ->
                        renderEditing config bounce.name
            else
                text <| bounce.name

        Nothing ->
            text "Untitled"


renderNameButtons : Config msg -> Bool -> List (Html msg)
renderNameButtons { toMsg } editing =
    if editing then
        [ button [ onClick (toMsg ApplyNameChangings) ] [ text "Apply" ]
        , button [ onClick (toMsg ToggleNameEdit) ] [ text "Cancel" ]
        ]
    else
        [ button [ onClick (toMsg ToggleNameEdit) ] [ text "Edit" ] ]
