module Events.Account.Finances.BankAccountClosed exposing (Data, handler)

import Json.Decode exposing (decodeValue)
import Decoders.Finances exposing (accountId)
import Events.Types exposing (Handler)
import Game.Account.Finances.Models exposing (..)


type alias Data =
    AccountId


handler : Handler Data event
handler event =
    decodeValue accountId >> Result.map event
