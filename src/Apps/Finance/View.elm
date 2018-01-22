module Apps.Finance.View exposing (view)

import Dict as Dict exposing (Dict)
import Html exposing (..)
import Html.CssHelpers
import UI.Layouts.VerticalList exposing (verticalList)
import UI.Layouts.VerticalSticked exposing (verticalSticked)
import UI.Widgets.HorizontalTabs exposing (hzTabs)
import Game.Account.Finances.Models as Finances
import Game.Account.Finances.Shared exposing (toMoney)
import Apps.Finance.Config exposing (..)
import Apps.Finance.Messages exposing (Msg(..))
import Apps.Finance.Models exposing (..)
import Apps.Finance.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view config model =
    let
        moneyTotal =
            config.finances
                |> Finances.getBankBalance
                |> toMoney

        bitcoinTotal =
            config.finances
                |> Finances.getBitcoinBalance

        finances =
            config.finances

        viewHeader =
            [ hzTabs (compareTabs model.selected) viewTabLabel GoTab tabs ]

        viewData =
            case model.selected of
                TabMoney ->
                    [ renderBankAccounts finances model
                    , text "Total USD Balance : "
                    , text moneyTotal
                    ]

                TabBitcoin ->
                    [ renderBitcoinAccounts finances model
                    , text "Total BTC Balance : "
                    , text (toString bitcoinTotal)
                    ]
    in
        verticalSticked (Just viewHeader) viewData Nothing
            |> Html.map config.toMsg


compareTabs : MainTab -> MainTab -> Bool
compareTabs =
    (==)


tabs : List MainTab
tabs =
    [ TabMoney
    , TabBitcoin
    ]


viewTabLabel : Bool -> MainTab -> ( List (Attribute Msg), List (Html Msg) )
viewTabLabel _ tab =
    tab
        |> tabToString
        |> text
        |> List.singleton
        |> (,) []


renderBitcoinAccount :
    Finances.BitcoinAddress
    -> Finances.BitcoinWallet
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


renderBitcoinAccounts : Finances.Model -> Model -> Html Msg
renderBitcoinAccounts finances model =
    finances
        |> Finances.getBitcoinWallets
        |> Dict.foldl renderBitcoinAccount []
        |> verticalList


renderBankAccount :
    Finances.AccountId
    -> Finances.BankAccount
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


renderBankAccounts : Finances.Model -> Model -> Html Msg
renderBankAccounts finances model =
    finances
        |> Finances.getBankAccounts
        |> Dict.foldl renderBankAccount []
        |> verticalList
