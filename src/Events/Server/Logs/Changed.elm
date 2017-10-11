module Events.Server.Logs.Changed exposing (..)

import Json.Decode exposing (decodeValue)
import Events.Types exposing (Handler)
import Decoders.Logs


type alias Data =
    Decoders.Logs.Index


handler : Handler Data event
handler event =
    decodeValue Decoders.Logs.index >> Result.map event
