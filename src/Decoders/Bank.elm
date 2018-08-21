module Decoders.Bank exposing (accountData, bankLogin)

import Json.Decode as Decode
    exposing
        ( Decoder
        , dict
        , int
        , float
        , string
        , field
        )
import Json.Decode.Pipeline exposing (decode, required, custom)
import Game.Bank.Shared exposing (BankAccountData)


accountData : Decoder BankAccountData
accountData =
    decode BankAccountData
        |> required "balance" int

accountId : Decoder (String, Int)
accountId =
    decode (,)
        |> required "atm_id" string
        |> required "account_number" int

bankLogin : Decoder ((String, Int), Int, String)
bankLogin =
    decode (,,)
        |> custom accountId
        |> required "balance" int
        |> required "password" string