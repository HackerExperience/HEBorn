module OS.SessionManager.Dock.Config exposing (..)

import Game.Account.Dock.Models as Dock
import Game.Servers.Shared exposing (CId)
import OS.SessionManager.WindowManager.Config as WindowManager
import OS.SessionManager.Dock.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , accountDock : Dock.Model
    , endpointCId : Maybe CId
    , sessionId : String
    , wmConfig : WindowManager.Config msg -- this is strange we need to change it someday
    , batchMsg : List msg -> msg
    }
