module Apps.Explorer.Config exposing (..)

import ContextMenu
import Html exposing (Attribute)
import Game.Servers.Models as Servers
import Game.Servers.Shared exposing (CId, StorageId)
import Game.Servers.Filesystem.Shared as Filesystem
import Apps.Explorer.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , activeServer : Servers.Server
    , menuAttr : ContextMenuAttribute msg
    , onNewTextFile : Filesystem.Path -> Filesystem.Name -> StorageId -> msg
    , onNewDir : Filesystem.Path -> Filesystem.Name -> StorageId -> msg
    , onMoveFile : Filesystem.Id -> Filesystem.Path -> StorageId -> msg
    , onRenameFile : Filesystem.Id -> Filesystem.Name -> StorageId -> msg
    , onDeleteFile : Filesystem.Id -> StorageId -> msg
    }



-- helpers


type alias ContextMenuItens msg =
    List (List ( ContextMenu.Item, msg ))


type alias ContextMenuAttribute msg =
    ContextMenuItens msg -> Attribute msg
