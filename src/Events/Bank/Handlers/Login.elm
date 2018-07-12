module Events.Bank.Handlers.Login exposing (Data, handler)

import Json.Decode exposing (decodeValue)
import Decoders.Bank exposing (..)
import Events.Shared exposing (Handler)
import Game.Account.Finances.Models exposing (..)

type alias Data =
    (AccountId, Int, String)

handler : Handler Data msg
handler toMsg =
    decodeValue bankLogin >> Result.map toMsg