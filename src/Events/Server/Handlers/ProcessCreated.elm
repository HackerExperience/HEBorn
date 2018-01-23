module Events.Server.Handlers.ProcessCreated exposing (..)

import Json.Decode exposing (decodeValue)
import Events.Shared exposing (Handler)
import Game.Servers.Processes.Models exposing (..)
import Decoders.Processes


type alias Data =
    ( ID, Process )


handler : Handler Data msg
handler toMsg =
    decodeValue Decoders.Processes.process >> Result.map toMsg
