module Apps.DBAdmin.Config exposing (..)

import ContextMenu
import Html exposing (Attribute)
import Game.Account.Database.Models as Database
import Apps.DBAdmin.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , database : Database.Model
    , batchMsg : List msg -> msg
    , openBrowser : String -> msg
    , menuAttr : ContextMenuAttribute msg
    }



-- helpers


type alias ContextMenuItens msg =
    List (List ( ContextMenu.Item, msg ))


type alias ContextMenuAttribute msg =
    ContextMenuItens msg -> Attribute msg
