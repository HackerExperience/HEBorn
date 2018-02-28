module Apps.LogViewer.Config exposing (..)

import ContextMenu
import Html exposing (Attribute)
import Game.Servers.Logs.Models as Logs
import Apps.LogViewer.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , logs : Logs.Model
    , menuAttr : ContextMenuAttribute msg
    , onUpdate : Logs.ID -> String -> msg
    , onEncrypt : Logs.ID -> msg
    , onHide : Logs.ID -> msg
    , onDelete : Logs.ID -> msg
    }



-- helpers


type alias ContextMenuItens msg =
    List (List ( ContextMenu.Item, msg ))


type alias ContextMenuAttribute msg =
    ContextMenuItens msg -> Attribute msg
