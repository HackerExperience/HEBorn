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
    , onUpdateLog : Logs.ID -> String -> msg
    , onEncryptLog : Logs.ID -> msg
    , onHideLog : Logs.ID -> msg
    , onDeleteLog : Logs.ID -> msg
    }



-- helpers


type alias ContextMenuItens msg =
    List (List ( ContextMenu.Item, msg ))


type alias ContextMenuAttribute msg =
    ContextMenuItens msg -> Attribute msg
