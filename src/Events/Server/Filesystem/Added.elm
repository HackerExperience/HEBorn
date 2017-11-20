module Events.Server.Filesystem.Added exposing (..)

import Json.Decode exposing (decodeValue, field)
import Events.Types exposing (Handler)
import Game.Servers.Filesystem.Models as Filesystem
import Decoders.Filesystem


type alias Data =
    Filesystem.FileEntry


handler : Handler Data event
handler event =
    decodeValue (field "file" Decoders.Filesystem.fileEntry)
        >> Result.map event
