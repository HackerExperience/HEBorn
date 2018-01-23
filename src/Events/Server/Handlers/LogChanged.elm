module Events.Server.Logs.Changed exposing (..)

import Json.Decode exposing (decodeValue)
import Events.Shared exposing (Handler)
import Decoders.Logs


type alias Data =
    Decoders.Logs.Index


handler : Handler Data msg
handler toMsg =
    decodeValue Decoders.Logs.index >> Result.map toMsg
