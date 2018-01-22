module Events.Account.Handlers.BankAccountUpdated exposing (Data, handler)

import Json.Decode exposing (decodeValue)
import Decoders.Finances exposing (bankAccountEntry)
import Events.Shared exposing (Handler)
import Game.Account.Finances.Models exposing (..)


type alias Data =
    ( AccountId, BankAccount )


handler : Handler Data msg
handler toMsg =
    decodeValue bankAccountEntry >> Result.map toMsg
