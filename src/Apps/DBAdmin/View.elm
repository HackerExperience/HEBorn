module Apps.DBAdmin.View exposing (view)

import Dict as Dict exposing (Dict)
import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import UI.Layouts.VerticalList exposing (verticalList)
import UI.Layouts.VerticalSticked exposing (verticalSticked)
import UI.Widgets.HorizontalTabs exposing (hzTabs)
import Apps.DBAdmin.Messages exposing (Msg(..))
import Apps.DBAdmin.Models exposing (..)
import Apps.DBAdmin.Resources exposing (Classes(..), prefix)
import Apps.DBAdmin.Tabs.Servers.View as Servers exposing (view)
import Game.Account.Finances.Shared exposing (toMoney)
import Game.Account.Database.Models as Database


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data ({ selected } as model) =
    let
        database =
            data.game.account.database

        viewData =
            case selected of
                TabServers ->
                    (Servers.view database model model)

                TabBankAccs ->
                    renderBankAccounts data database model

                TabWallets ->
                    renderBitcoinAccounts data database model

        viewTabs =
            hzTabs (compareTabs selected) viewTabLabel GoTab tabs
    in
        verticalSticked
            (Just [ viewTabs ])
            [ viewData ]
            Maybe.Nothing


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


renderBitcoinAccount :
    Database.HackedBitcoinAddress
    -> Database.HackedBitcoinWallet
    -> List (Html Msg)
    -> List (Html Msg)
renderBitcoinAccount address account acc =
    let
        account_ =
            [ text "Bitcoin Wallet: ", text account.address ]

        accountContent =
            [ text <| "BTC : " ++ (toString account.balance) ]

        content =
            div
                [ class [ FinanceEntry ] ]
                [ div [ class [ LeftSide ] ] account_
                , div [ class [ RightSide ] ] accountContent
                ]
    in
        content :: acc


renderBitcoinAccounts : Game.Data -> Database.Model -> Model -> Html Msg
renderBitcoinAccounts data database model =
    database
        |> Database.getBitcoinWallets
        |> Dict.foldl renderBitcoinAccount []
        |> verticalList


renderBankAccount :
    Database.HackedBankAccountID
    -> Database.HackedBankAccount
    -> List (Html Msg)
    -> List (Html Msg)
renderBankAccount id account acc =
    let
        accountNumber =
            Tuple.second id

        account_ =
            [ text account.name, text " ", text (toString accountNumber) ]

        accountContent =
            [ text <| "USD : " ++ (toMoney account.balance) ]

        content =
            div
                [ class [ FinanceEntry ] ]
                [ div [ class [ LeftSide ] ] account_
                , div [ class [ RightSide ] ] accountContent
                ]
    in
        content :: acc


renderBankAccounts : Game.Data -> Database.Model -> Model -> Html Msg
renderBankAccounts data database model =
    database
        |> Database.getBankAccounts
        |> Dict.foldl renderBankAccount []
        |> verticalList
