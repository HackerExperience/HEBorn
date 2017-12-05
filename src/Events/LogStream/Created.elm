module Events.LogStream.Created exposing (..)

import Json.Decode exposing (decodeValue)
import Events.Types exposing (Handler)
import Game.LogStream.Models exposing (Log)
import Decoders.LogStream


type alias Data =
    Log


handler : Handler Data event
handler event =
    decodeValue Decoders.LogStream.log >> Result.map event
