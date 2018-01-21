module OS.SessionManager.Config exposing (..)

import Time exposing (Time)
import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Meta.Types.Context exposing (Context(..))
import OS.SessionManager.WindowManager.Config as WindowManager
import OS.SessionManager.Dock.Config as Dock
import Apps.Config as Apps
import OS.SessionManager.Types exposing (..)
import OS.SessionManager.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , lastTick : Time
    , account : Account.Model
    , activeServer : Servers.Server
    , activeContext : Context
    }


wmConfig : String -> Config msg -> WindowManager.Config msg
wmConfig sessionId { toMsg, lastTick, account, activeServer } =
    { toMsg = WindowManagerMsg sessionId >> toMsg
    , lastTick = lastTick
    , account = account
    , activeServer = activeServer
    }


dockConfig : Config msg -> Dock.Config msg
dockConfig config =
    { toMsg = DockMsg >> config.toMsg
    }
