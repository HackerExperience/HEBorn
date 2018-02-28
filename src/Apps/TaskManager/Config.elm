module Apps.TaskManager.Config exposing (..)

import ContextMenu
import Html exposing (Attribute)
import Time exposing (Time)
import Game.Servers.Processes.Models as Processes
import Apps.TaskManager.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , processes : Processes.Model
    , lastTick : Time
    , menuAttr : ContextMenuAttribute msg
    , onPause : Processes.ID -> msg
    , onResume : Processes.ID -> msg
    , onRemove : Processes.ID -> msg
    }



-- helpers


type alias ContextMenuItens msg =
    List (List ( ContextMenu.Item, msg ))


type alias ContextMenuAttribute msg =
    ContextMenuItens msg -> Attribute msg
