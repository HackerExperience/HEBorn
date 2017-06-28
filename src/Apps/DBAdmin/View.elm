module Apps.DBAdmin.View exposing (view)

import Html exposing (Html, div, text)
import Game.Data as Game
import UI.Layouts.HorizontalTabs exposing (horizontalTabs)
import Apps.DBAdmin.Messages exposing (Msg(..))
import Apps.DBAdmin.Models exposing (..)
import Apps.DBAdmin.Tabs exposing (toComparable)
import Apps.DBAdmin.Tabs.Servers.View as Servers exposing (view)


tabs : List ( Int, Html Msg )
tabs =
    [ ( toComparable TabServers, text "Servers" )
    , ( toComparable TabBankAccs, text "Bank Accounts" )
    , ( toComparable TabWallets, text "BTC Wallets" )
    ]


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    let
        viewData =
            case app.selected of
                TabServers ->
                    (Servers.view data.game.account.database model app)

                TabBankAccs ->
                    (div [] [])

                TabWallets ->
                    (div [] [])
    in
        horizontalTabs
            [ viewData ]
            (toComparable app.selected)
            tabs
            GoTab
