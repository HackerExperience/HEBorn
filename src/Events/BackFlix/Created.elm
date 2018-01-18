module Events.BackFlix.Created exposing (..)

import Json.Decode exposing (decodeValue)
import Events.Types exposing (Handler)
import Game.BackFlix.Models exposing (Log)
import Decoders.BackFlix


type alias Data =
    Log


handler : Handler Data event
handler event =
    decodeValue Decoders.BackFlix.log >> Result.map event
