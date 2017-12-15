module Events.Account.Finances.BankAccountOpened exposing (Data, handler)

import Json.Decode exposing (decodeValue)
import Decoders.Finances exposing (bankAccountEntry)
import Events.Types exposing (Handler)
import Game.Account.Finances.Models exposing (..)


type alias Data =
    ( AccountId, BankAccount )


handler : Handler Data event
handler event =
    decodeValue bankAccountEntry >> Result.map event
