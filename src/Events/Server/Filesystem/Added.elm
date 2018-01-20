module Events.Server.Filesystem.Added exposing (..)

import Json.Decode exposing (decodeValue, field)
import Events.Types exposing (Handler)
import Game.Servers.Shared as Servers
import Game.Servers.Filesystem.Shared as Filesystem
import Decoders.Filesystem
import Decoders.Servers


type alias Data =
    Filesystem.FileEntry


handler : Handler ( Servers.StorageId, Data ) event
handler event =
    decodeValue
        (field "file" <|
            Decoders.Servers.withStorageId Decoders.Filesystem.fileEntry
        )
        >> Result.map event
