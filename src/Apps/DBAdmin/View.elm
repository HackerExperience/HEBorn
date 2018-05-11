module Apps.DBAdmin.View exposing (view)

import Dict as Dict exposing (Dict)
import Html exposing (..)
import Html.CssHelpers
import UI.Layouts.VerticalList exposing (verticalList)
import UI.Layouts.VerticalSticked exposing (verticalSticked)
import UI.Elements.HorizontalTabs exposing (hzTabs)
import Apps.DBAdmin.Config exposing (..)
import Apps.DBAdmin.Messages exposing (Msg(..))
import Apps.DBAdmin.Models exposing (..)
import Apps.DBAdmin.Resources exposing (Classes(..), prefix)
import Apps.DBAdmin.Tabs.Servers.View as Servers exposing (view)
import Game.Account.Finances.Shared exposing (toMoney)
import Game.Account.Database.Models as Database


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view config ({ selected } as model) =
    let
        database =
            config.database

        viewData =
            case selected of
                TabServers ->
                    (Servers.view config model)

                TabBankAccs ->
                    Html.map config.toMsg <|
                        renderBankAccounts database model

                TabWallets ->
                    Html.map config.toMsg <|
                        renderBitcoinAccounts database model

        viewTabs =
            hzTabs
                (compareTabs selected)
                viewTabLabel
                (GoTab >> config.toMsg)
                tabs
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


viewTabLabel : Bool -> MainTab -> ( List (Attribute msg), List (Html msg) )
viewTabLabel _ tab =
    tab
        |> tabToString
        |> text
        |> List.singleton
        |> (,) []


renderBitcoinAccount :
    Database.HackedBitcoinAddress
    -> Database.HackedBitcoinWallet
    -> List (Html msg)
    -> List (Html msg)
renderBitcoinAccount address account acc =
    let
        account_ =
            [ text "Bitcoin Wallet: ", text address ]

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


renderBitcoinAccounts : Database.Model -> Model -> Html msg
renderBitcoinAccounts database model =
    database
        |> Database.getBitcoinWallets
        |> Dict.foldl renderBitcoinAccount []
        |> verticalList []


renderBankAccount :
    Database.HackedBankAccountID
    -> Database.HackedBankAccount
    -> List (Html msg)
    -> List (Html msg)
renderBankAccount id account acc =
    let
        accountNumber =
            Tuple.second id

        account_ =
            [ text account.name, text " ", text (toString accountNumber) ]

        knownBalance =
            account.knownBalance
                |> Maybe.map toMoney
                |> Maybe.withDefault "?"

        accountContent =
            [ text <| "USD : " ++ knownBalance
            ]

        content =
            div
                [ class [ FinanceEntry ] ]
                [ div [ class [ LeftSide ] ] account_
                , div [ class [ RightSide ] ] accountContent
                ]
    in
        content :: acc


renderBankAccounts : Database.Model -> Model -> Html msg
renderBankAccounts database model =
    database
        |> Database.getBankAccounts
        |> Dict.foldl renderBankAccount []
        |> verticalList []
