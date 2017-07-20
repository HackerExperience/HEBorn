module Apps.DBAdmin.View exposing (view)

import Html exposing (Html, Attribute, div, text)
import Game.Data as Game
import UI.Layouts.VerticalSticked exposing (verticalSticked)
import UI.Widgets.HorizontalTabs exposing (hzTabs)
import Apps.DBAdmin.Messages exposing (Msg(..))
import Apps.DBAdmin.Models exposing (..)
import Apps.DBAdmin.Tabs.Servers.View as Servers exposing (view)


tabs : List MainTab
tabs =
    [ TabServers
    , TabBankAccs
    , TabWallets
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


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    let
        { selected } =
            app

        viewData =
            case selected of
                TabServers ->
                    (Servers.view data.game.account.database model app)

                TabBankAccs ->
                    (div [] [ text "SOON" ])

                TabWallets ->
                    (div [] [ text "SOON" ])

        viewTabs =
            hzTabs (compareTabs selected) viewTabLabel GoTab tabs
    in
        verticalSticked
            (Just [ viewTabs ])
            [ viewData ]
            Maybe.Nothing
