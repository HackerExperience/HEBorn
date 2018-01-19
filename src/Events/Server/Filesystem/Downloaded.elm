module Events.Server.Filesystem.Downloaded exposing (..)

import Json.Decode exposing (decodeValue)
import Events.Types exposing (Handler)
import Game.Servers.Shared as Servers
import Game.Servers.Filesystem.Shared as Filesystem
import Decoders.Filesystem
import Decoders.Servers


type alias Data =
    Filesystem.FileEntry


handler : Handler ( Servers.StorageId, Data ) event
handler event =
    decodeValue (Decoders.Servers.withStorageId Decoders.Filesystem.fileEntry)
        >> Result.map event
