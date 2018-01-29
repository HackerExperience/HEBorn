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
    , onNewTextFile : StorageId -> Filesystem.Path -> Filesystem.Name -> msg
    , onNewDir : StorageId -> Filesystem.Path -> Filesystem.Name -> msg
    , onMoveFile : StorageId -> Filesystem.Id -> Filesystem.Path -> msg
    , onRenameFile : StorageId -> Filesystem.Id -> Filesystem.Name -> msg
    , onDeleteFile : StorageId -> Filesystem.Id -> msg
    }



-- helpers


type alias ContextMenuItens msg =
    List (List ( ContextMenu.Item, msg ))


type alias ContextMenuAttribute msg =
    ContextMenuItens msg -> Attribute msg
