module Apps.Explorer.Menu.Config exposing (..)

import Game.Servers.Models as Servers
import Game.Servers.Shared exposing (CId, StorageId)
import Game.Servers.Filesystem.Shared as Filesystem
import Apps.Explorer.Menu.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , activeServer : Servers.Server
    , batchMsg : List msg -> msg
    , onNewTextFile : StorageId -> Filesystem.Path -> Filesystem.Name -> msg
    , onNewDir : StorageId -> Filesystem.Path -> Filesystem.Name -> msg
    , onMoveFile : StorageId -> Filesystem.Id -> Filesystem.Path -> msg
    , onRenameFile : StorageId -> Filesystem.Id -> Filesystem.Name -> msg
    , onDeleteFile : StorageId -> Filesystem.Id -> msg
    }
