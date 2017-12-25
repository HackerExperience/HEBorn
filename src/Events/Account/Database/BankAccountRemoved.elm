module Events.Account.Database.BankAccountRemoved exposing (Data, handler)

import Json.Decode exposing (decodeValue)
import Decoders.Database exposing (hackedBankAccountId)
import Events.Types exposing (Handler)
import Game.Account.Database.Models exposing (..)


type alias Data =
    HackedBankAccountID


handler : Handler Data event
handler event =
    decodeValue hackedBankAccountId >> Result.map event
