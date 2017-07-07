module Apps.Finance.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import UI.Layouts.VerticalList exposing (verticalList)
import Apps.Finance.Messages exposing (Msg(..))
import Apps.Finance.Models exposing (..)
import Apps.Finance.Resources exposing (Classes(..), prefix)
import Apps.Finance.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


type MoneySrc
    = BTCWallet String
    | BankAccount Int


type MoneyCoin
    = BTC Float
    | USD Float


entryView : ( MoneySrc, MoneyCoin ) -> Html Msg
entryView ( src, val ) =
    let
        ( srcText, entryClass ) =
            case src of
                BTCWallet token ->
                    ( "WALLET " ++ token, Bitcoin )

                BankAccount id ->
                    ( "ACCOUNT " ++ (toString id), RealMoney )

        valText =
            case val of
                BTC val ->
                    "BTC " ++ (toString val)

                USD val ->
                    "USD " ++ (toString val)
    in
        div
            [ class [ FinanceEntry, entryClass ] ]
            [ span [] [ text valText ], div [] [ text srcText ] ]


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    [ ( BTCWallet "deadbeef", BTC 8.351 )
    , ( BankAccount 1337, USD 89 )
    , ( BankAccount 1337, USD 12.85 )
    , ( BTCWallet "deadbeef", BTC 50.1 )
    , ( BTCWallet "deadbeef", BTC 7.657 )
    ]
        |> List.map entryView
        |> (::) (menuView model)
        |> verticalList
