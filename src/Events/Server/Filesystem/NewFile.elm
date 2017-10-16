module Events.Server.Filesystem.NewFile exposing (..)

import Json.Decode exposing (decodeValue)
import Events.Types exposing (Handler)
import Game.Servers.Filesystem.Shared exposing (Foreigner)
import Decoders.Filesystem


type alias Data =
    Foreigner


handler : Handler Data event
handler event =
    decodeValue (Decoders.Filesystem.entry ()) >> Result.map event
