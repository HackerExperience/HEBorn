module Apps.BounceManager.View exposing (view)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import UI.Inlines.Networking as Inlines
import UI.Layouts.FlexColumns exposing (flexCols)
import UI.Layouts.VerticalSticked exposing (verticalSticked)
import UI.Layouts.VerticalList exposing (verticalList)
import UI.Widgets.HorizontalTabs exposing (hzTabs)
import Game.Account.Database.Models exposing (HackedServer)
import Game.Account.Bounces.Models as Bounces exposing (Bounce, IP)
import Apps.BounceManager.Messages exposing (Msg(..))
import Apps.BounceManager.Models exposing (..)
import Apps.BounceManager.Resources exposing (Classes(..), prefix)
import Apps.BounceManager.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


tabs : List MainTab
tabs =
    [ TabManage
    , TabCreate
    ]


compareTabs : MainTab -> MainTab -> Bool
compareTabs =
    (==)


viewTabLabel : Bool -> MainTab -> List (Html Msg)
viewTabLabel _ tab =
    tab
        |> tabToString
        |> text
        |> List.singleton


viewBouncePath : List IP -> Html Msg
viewBouncePath ips =
    ips
        |> List.map Inlines.addr
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
        , viewBouncePath <| val.path
        ]


viewTabManage : Bounces.Model -> Html Msg
viewTabManage src =
    src
        |> Dict.toList
        |> List.map viewBounce
        |> verticalList


viewSelectServer : HackedServer -> Html Msg
viewSelectServer srv =
    text srv.ip


viewTabCreate : List HackedServer -> Html Msg
viewTabCreate servers =
    let
        available =
            servers
                |> List.map viewSelectServer
    in
        flexCols
            [ div [] available
            , div [] [ text "SOON" ]
            ]


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    let
        { selected } =
            app

        contentStc =
            data.game.account.bounces

        hckdServers =
            data.game.account.database.servers

        viewData =
            case selected of
                TabManage ->
                    (viewTabManage contentStc)

                TabCreate ->
                    (viewTabCreate hckdServers)

        viewTabs =
            hzTabs (compareTabs selected) viewTabLabel GoTab tabs
    in
        verticalSticked
            (Just [ viewTabs ])
            [ viewData, menuView model ]
            Nothing
