module Events.Server.Handlers.LogCreated exposing (..)

import Json.Decode exposing (decodeValue)
import Events.Shared exposing (Handler)
import Decoders.Logs


type alias Data =
    Decoders.Logs.LogWithIndex


handler : Handler Data msg
handler toMsg =
    decodeValue Decoders.Logs.logWithId >> Result.map toMsg
