module Apps.Explorer.Config exposing (..)

import Game.Servers.Models as Servers
import Game.Servers.Shared exposing (CId, StorageId)
import Game.Servers.Filesystem.Shared as Filesystem
import Apps.Explorer.Menu.Config as Menu
import Apps.Explorer.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , activeServer : Servers.Server
    , onNewTextFile : StorageId -> Filesystem.Path -> Filesystem.Name -> msg
    , onNewDir : StorageId -> Filesystem.Path -> Filesystem.Name -> msg
    , onMoveFile : StorageId -> Filesystem.Id -> Filesystem.Path -> msg
    , onRenameFile : StorageId -> Filesystem.Id -> Filesystem.Name -> msg
    , onDeleteFile : StorageId -> Filesystem.Id -> msg
    }


menuConfig : Config msg -> Menu.Config msg
menuConfig config =
    { toMsg = MenuMsg >> config.toMsg
    , activeServer = config.activeServer
    , batchMsg = config.batchMsg
    , onNewTextFile = config.onNewTextFile
    , onNewDir = config.onNewDir
    , onMoveFile = config.onMoveFile
    , onRenameFile = config.onRenameFile
    , onDeleteFile = config.onDeleteFile
    }
