module Apps.BounceManager.View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers
import Game.Account.Database.Models as Database exposing (HackedServers)
import Game.Account.Bounces.Models as Bounces exposing (Bounce)
import Game.Account.Bounces.Shared as Bounces
import Game.Meta.Types.Network as Network
import UI.Layouts.FlexColumns exposing (flexCols)
import UI.Layouts.VerticalSticked exposing (verticalSticked)
import UI.Layouts.VerticalList exposing (verticalList)
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
        contentStc =
            config.bounces

        hckdServers =
            config.database
                |> Database.getHackedServers

        viewData =
            case selected of
                TabManage ->
                    (viewTabManage contentStc)

                TabBuild ->
                    (viewTabBuild config hckdServers model)

        viewTabs =
            hzTabs (compareTabs selected) viewTabLabel (GoTab >> config.toMsg) tabs
    in
        verticalSticked (Just [ viewTabs ]) [ viewData ] Nothing


tabs : List MainTab
tabs =
    [ TabManage
    , TabBuild
    ]


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


viewTabManage : Bounces.Model -> Html msg
viewTabManage src =
    src
        |> Dict.toList
        |> List.map viewBounce
        |> verticalList


viewTabBuild : Config msg -> Database.HackedServers -> Model -> Html msg
viewTabBuild config servers model =
    [ div [] [ text model.activeBounce.name ]
    , flexCols
        [ div [] [ renderAvailableServers servers model ]
        , div [] [ renderBounceBuilder config model ]
        ]
    ]


renderAvailableServers : Database.HackedServers -> Model -> Html msg
renderAvailableServers hackedServers model =
    hackedServers
        |> Dict.toList
        |> List.map (uncurry <| renderAvailableServer model)
        |> verticalList


renderAvailableServer :
    Model
    -> Network.NIP
    -> Database.HackedServer
    -> List (Html msg)
    -> List (Html msg)
renderAvailableServer model nip server acu =
    let
        servers =
            [ renderMaybeString "Label" server.label
            , br [] []
            , renderConsistentField "IP" (Tuple.second nip)
            ]
    in
        (div [ class [ HackedServer ] ] servers) :: acu


renderMaybeString : String -> Maybe String -> Html msg
renderMaybeString field maybeString =
    case maybeString of
        Just string ->
            text <| field ++ ": " ++ string

        Nothing ->
            text ""


renderConsistentField : String -> String -> Html msg
renderConsistentField field value =
    text <| field ++ ": " ++ value


renderBounceBuilder : Config msg -> Model -> Html msg
renderBounceBuilder config model =
    model.getActiveBounce.path
        |> List.foldl (renderBounceNode config model) []
        |> div []


renderBounceNode : Config msg -> Model -> Network.NIP -> Html msg
renderBounceNode config model nip =
    div [ class [ BounceNode ] ] [ text <| Network.toString nip ]


renderMoveMenu : Config msg -> Model -> Html msg
renderMoveMenu config model =
    div [ class [ MoveMenu ] ]
        [ button [ value "/\\" ] []
        , button [ value "\\/" ] []
        , button [ value "X" ] []
        ]
