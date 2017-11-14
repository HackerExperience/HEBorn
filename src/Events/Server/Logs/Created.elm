module Events.Server.Logs.Created exposing (..)

import Json.Decode exposing (decodeValue)
import Events.Types exposing (Handler)
import Decoders.Logs


type alias Data =
    Decoders.Logs.LogWithIndex


handler : Handler Data event
handler event =
    decodeValue Decoders.Logs.logWithId >> Result.map event
