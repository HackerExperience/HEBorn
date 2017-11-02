module Events.Server.Filesystem.NewFile exposing (..)

import Json.Decode exposing (decodeValue)
import Events.Types exposing (Handler)
import Game.Servers.Filesystem.Models as Filesystem
import Decoders.Filesystem


type alias Data =
    Filesystem.FileEntry


handler : Handler Data event
handler event =
    decodeValue (Decoders.Filesystem.fileEntry) >> Result.map event
