module Events.Server.Processes.Changed exposing (..)

import Json.Decode exposing (decodeValue)
import Events.Types exposing (Handler)
import Game.Servers.Processes.Models exposing (..)
import Decoders.Processes


type alias Data =
    Processes


handler : Handler Data event
handler event =
    decodeValue Decoders.Processes.processDict >> Result.map event
