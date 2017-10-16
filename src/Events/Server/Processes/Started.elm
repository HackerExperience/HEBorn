module Events.Server.Processes.Started exposing (..)

import Json.Decode exposing (decodeValue)
import Events.Types exposing (Handler)
import Game.Servers.Processes.Models exposing (..)
import Decoders.Processes


type alias Data =
    ( ID, Process )


handler : Handler Data event
handler event =
    decodeValue Decoders.Processes.process >> Result.map event
