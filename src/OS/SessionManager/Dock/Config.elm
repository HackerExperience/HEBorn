module OS.SessionManager.Dock.Config exposing (..)

import ContextMenu
import Html exposing (Attribute)
import Game.Account.Dock.Models as Dock
import Game.Servers.Shared exposing (CId)
import OS.SessionManager.WindowManager.Config as WindowManager
import OS.SessionManager.Dock.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , accountDock : Dock.Model
    , endpointCId : Maybe CId
    , sessionId : String
    , menuAttr : ContextMenuAttribute msg
    , wmConfig : WindowManager.Config msg -- this is TOTALLY WRONG we need to change it someday
    }



-- helpers


type alias ContextMenuItens msg =
    List (List ( ContextMenu.Item, msg ))


type alias ContextMenuAttribute msg =
    ContextMenuItens msg -> Attribute msg
