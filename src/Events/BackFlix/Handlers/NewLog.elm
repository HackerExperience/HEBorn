module Events.BackFlix.Handlers.NewLog exposing (..)

import Json.Decode exposing (decodeValue)
import Events.Shared exposing (Handler)
import Game.BackFlix.Models exposing (Log)
import Decoders.BackFlix


type alias Data =
    Log


handler : Handler Data msg
handler toMsg =
    decodeValue Decoders.BackFlix.log >> Result.map toMsg
