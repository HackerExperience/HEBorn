module OS.SessionManager.Config exposing (..)

import Game.Meta.Types.Context exposing (Context(..))
import OS.SessionManager.WindowManager.Config as WindowManager
import OS.SessionManager.Dock.Config as Dock
import Apps.Config as Apps
import OS.SessionManager.Types exposing (..)
import OS.SessionManager.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    }


wmConfig : String -> Config msg -> WindowManager.Config msg
wmConfig sessionId config =
    { toMsg = WindowManagerMsg sessionId >> config.toMsg
    }


dockConfig : Config msg -> Dock.Config msg
dockConfig config =
    { toMsg = DockMsg >> config.toMsg
    }


appsConfig : WindowRef -> Context -> Config msg -> Apps.Config msg
appsConfig windowRef context config =
    { toMsg = AppMsg windowRef context >> config.toMsg
    }
