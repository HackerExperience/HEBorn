module Decoders.Bank exposing (accountData, loginError)

import Json.Decode as Decode
    exposing
        ( Decoder
        , dict
        , int
        , float
        , string
        )
import Json.Decode.Pipeline exposing (decode, required)
import Game.Account.Bounces.Models exposing (..)
import Apps.Browser.Pages.Bank.Models exposing (AccountData)


accountData : Decoder AccountData
accountData =
    decode AccountData
        |> required "balance" int


loginError : Decoder String
loginError =
    decode string
        |> field "error"
