module Events.Account.Handlers.DbAccountUpdated exposing (Data, handler)

import Json.Decode exposing (decodeValue)
import Decoders.Database exposing (bankAccountEntry)
import Events.Shared exposing (Handler)
import Game.Account.Database.Models exposing (..)


type alias Data =
    ( HackedBankAccountID, HackedBankAccount )


handler : Handler Data msg
handler toMsg =
    decodeValue bankAccountEntry >> Result.map toMsg
