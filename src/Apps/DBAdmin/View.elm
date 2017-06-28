module Apps.DBAdmin.View exposing (view)

import Html exposing (Html, div, text)
import Game.Data as Game
import UI.Layouts.HorizontalTabs exposing (hzTabs)
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
compareTabs a b =
    (tabToString a) == (tabToString b)


viewTabLabel : Bool -> MainTab -> List (Html Msg)
viewTabLabel _ tab =
    tab
        |> tabToString
        |> text
        |> List.singleton


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
                    (div [] [])

                TabWallets ->
                    (div [] [])
    in
        hzTabs (compareTabs selected) viewTabLabel GoTab tabs
