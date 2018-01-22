module Events.Server.Handlers.FileDownloaded exposing (..)

import Json.Decode exposing (decodeValue)
import Events.Shared exposing (Handler)
import Game.Servers.Shared as Servers
import Game.Servers.Filesystem.Shared as Filesystem
import Decoders.Filesystem
import Decoders.Servers


type alias Data =
    ( Servers.StorageId, Filesystem.FileEntry )


handler : Handler Data msg
handler toMsg =
    decodeValue (Decoders.Servers.withStorageId Decoders.Filesystem.fileEntry)
        >> Result.map toMsg
