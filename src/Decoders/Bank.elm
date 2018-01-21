module Decoders.Bank exposing (accountData)

import Json.Decode as Decode
    exposing
        ( Decoder
        , dict
        , int
        , float
        , string
        , field
        )
import Json.Decode.Pipeline exposing (decode, required)
import Game.Account.Finances.Shared exposing (BankAccountData)


accountData : Decoder BankAccountData
accountData =
    decode BankAccountData
        |> required "balance" int
