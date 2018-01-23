module Events.Account.Handlers.BankAccountClosed exposing (Data, handler)

import Json.Decode exposing (decodeValue)
import Decoders.Finances exposing (accountId)
import Events.Shared exposing (Handler)
import Game.Account.Finances.Models exposing (..)


type alias Data =
    AccountId


handler : Handler Data msg
handler toMsg =
    decodeValue accountId >> Result.map toMsg
