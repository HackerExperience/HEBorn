module Events.Account.Database.DBAccountAcquired exposing (Data, handler)

import Json.Decode exposing (decodeValue)
import Decoders.Database exposing (bankAccountEntry)
import Events.Types exposing (Handler)
import Game.Account.Database.Models exposing (..)


type alias Data =
    ( HackedBankAccountID, HackedBankAccount )


handler : Handler Data event
handler event =
    decodeValue bankAccountEntry >> Result.map event
