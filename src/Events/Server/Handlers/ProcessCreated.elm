module Events.Server.Handlers.ProcessCreated exposing (..)

import Json.Decode exposing (decodeValue)
import Events.Shared exposing (Handler)
import Game.Servers.Processes.Models exposing (..)
import Game.Servers.Processes.Shared exposing (..)
import Decoders.Processes exposing (process)


type alias Data =
    ( ID, Process )


handler : Handler Data msg
handler toMsg =
    decodeValue process >> Result.map toMsg
