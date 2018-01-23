module Apps.BounceManager.View exposing (view)

import Dict
import Html exposing (..)
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
import Apps.BounceManager.Messages exposing (Msg(..))
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

                TabCreate ->
                    (viewTabCreate hckdServers)

        viewTabs =
            hzTabs (compareTabs selected) viewTabLabel GoTab tabs
    in
        Html.map config.toMsg <|
            verticalSticked
                (Just [ viewTabs ])
                [ viewData ]
                Nothing


tabs : List MainTab
tabs =
    [ TabManage
    , TabCreate
    ]


compareTabs : MainTab -> MainTab -> Bool
compareTabs =
    (==)


viewTabLabel : Bool -> MainTab -> ( List (Attribute Msg), List (Html Msg) )
viewTabLabel _ tab =
    tab
        |> tabToString
        |> text
        |> List.singleton
        |> (,) []


viewBouncePath : List Network.NIP -> Html Msg
viewBouncePath ips =
    ips
        |> List.map (Tuple.second >> text)
        |> List.intersperse (text " > ")
        |> span []


viewBounce : ( Bounces.ID, Bounce ) -> Html Msg
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


viewTabManage : Bounces.Model -> Html Msg
viewTabManage src =
    src
        |> Dict.toList
        |> List.map viewBounce
        |> verticalList


viewTabCreate : HackedServers -> Html Msg
viewTabCreate servers =
    let
        available =
            servers
                |> Dict.keys
                |> List.map (Network.toString >> text)
    in
        flexCols
            [ div [] available
            , div [] [ text "SOON" ]
            ]
