module Apps.BounceManager.View exposing (view)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import UI.Inlines.Networking as Inlines
import UI.Layouts.VerticalSticked exposing (verticalSticked)
import UI.Layouts.VerticalList exposing (verticalList)
import UI.Widgets.HorizontalTabs exposing (hzTabs)
import Game.Network.Models exposing (Bounces, BounceID, Bounce, IP)
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


viewBounceChain : List IP -> Html Msg
viewBounceChain ips =
    ips
        |> List.map Inlines.addr
        |> List.intersperse (text " > ")
        |> span []


viewBounce : ( BounceID, Bounce ) -> Html Msg
viewBounce ( id, val ) =
    div [ class [ BounceEntry ] ]
        [ text "ID: "
        , text (toString id)
        , br [] []
        , text "Name: "
        , text val.name
        , br [] []
        , text "Chain: "
        , viewBounceChain <| val.chain
        ]


viewTabManage : Bounces -> Html Msg
viewTabManage src =
    src
        |> Dict.toList
        |> List.map viewBounce
        |> verticalList


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    let
        { selected } =
            app

        contentStc =
            data.game.network.bounces

        viewData =
            case selected of
                TabManage ->
                    (viewTabManage contentStc)

                TabCreate ->
                    (div [] [ text "SOON" ])

        viewTabs =
            hzTabs (compareTabs selected) viewTabLabel GoTab tabs
    in
        verticalSticked
            (Just [ viewTabs ])
            [ viewData, menuView model ]
            Nothing
