module Decoders.Finances exposing (..)

import Dict
import Json.Decode as Decode
    exposing
        ( Decoder
        , field
        , map
        , string
        , int
        , list
        )
import Json.Decode.Pipeline exposing (decode, required, custom, hardcoded)
import Game.Account.Finances.Models exposing (..)


finances : Decoder Model
finances =
    decode Model
        |> required "bank" bank
        |> hardcoded Dict.empty


bank : Decoder BankAccounts
bank =
    map Dict.fromList <| list bankAccountEntry


bankAccountEntry : Decoder ( AccountId, BankAccount )
bankAccountEntry =
    decode (,)
        |> custom accountId
        |> custom bankAccount


bankAccount : Decoder BankAccount
bankAccount =
    decode BankAccount
        |> required "name" string
        |> required "password" string
        |> required "balance" int


accountId : Decoder AccountId
accountId =
    decode (,)
        |> required "atm_id" string
        |> required "account_num" int
