module Game.Account.Finances.Models exposing (..)

import Dict as Dict exposing (Dict)
import Game.Servers.Shared exposing (Id)
import Game.Meta.Types.Components as Components


type alias Model =
    { bank : BankAccounts
    , bitcoin : BitcoinWallets
    }


type alias AtmId =
    Id


type alias BankAccounts =
    Dict AccountId BankAccount


type alias BitcoinWallets =
    Dict BitcoinAddress BitcoinWallet


type alias AccountId =
    ( AtmId, AccountNumber )


type alias AccountNumber =
    Int


type alias BankAccount =
    { name : String
    , password : String
    , balance : Int
    }


type alias BitcoinAddress =
    String


type alias BitcoinWallet =
    { address : String
    , balance : Float
    }


type alias Shop =
    Id


type alias Product =
    Components.Id


type PaymentType
    = Purchase Shop Product Int -- Int for Product Value


initialModel : Model
initialModel =
    { bank = Dict.empty
    , bitcoin = Dict.empty
    }


getBankAccounts : Model -> BankAccounts
getBankAccounts =
    .bank


getBitcoinWallets : Model -> BitcoinWallets
getBitcoinWallets =
    .bitcoin


insertBankAccount : AccountId -> BankAccount -> Model -> Model
insertBankAccount id account model =
    let
        bank =
            Dict.insert id account model.bank
    in
        { model | bank = bank }


insertBitcoinWallet : BitcoinAddress -> BitcoinWallet -> Model -> Model
insertBitcoinWallet address account model =
    let
        bitcoin =
            Dict.insert address account model.bitcoin
    in
        { model | bitcoin = bitcoin }


removeBankAccount : AccountId -> Model -> Model
removeBankAccount id model =
    let
        bank =
            Dict.remove id model.bank
    in
        { model | bank = bank }


removeBitcoinWallet : BitcoinAddress -> Model -> Model
removeBitcoinWallet address model =
    let
        bitcoin =
            Dict.remove address model.bitcoin
    in
        { model | bitcoin = bitcoin }


getBankBalance : Model -> Int
getBankBalance model =
    Dict.foldl (\k v acc -> acc + v.balance) 0 model.bank


getBitcoinBalance : Model -> Float
getBitcoinBalance model =
    Dict.foldl (\k v acc -> acc + v.balance) 0 model.bitcoin


setBankAccounts : BankAccounts -> Model -> Model
setBankAccounts bank model =
    { model | bank = bank }


setBitcoinWallets : BitcoinWallets -> Model -> Model
setBitcoinWallets bitcoin model =
    { model | bitcoin = bitcoin }


setFinances : BankAccounts -> BitcoinWallets -> Model -> Model
setFinances bank bitcoin model =
    { model | bank = bank, bitcoin = bitcoin }
