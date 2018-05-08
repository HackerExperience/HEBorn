module Events.Server.Handlers.FileDownloaded exposing (..)

import Json.Decode exposing (decodeValue, field)
import Events.Shared exposing (Handler)
import Game.Servers.Shared as Servers
import Game.Servers.Filesystem.Shared as Filesystem
import Decoders.Filesystem
import Decoders.Servers


type alias Data =
    ( Servers.StorageId, Filesystem.FileEntry )


handler : Handler Data msg
handler toMsg =
    (Decoders.Filesystem.fileEntry
        |> Decoders.Servers.withStorageId
        |> field "file"
        |> decodeValue
    )
        >> Result.map toMsg
