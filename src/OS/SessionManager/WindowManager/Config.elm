module OS.SessionManager.WindowManager.Config exposing (..)

import Time exposing (Time)
import Apps.Config as Apps
import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Storyline.Models as Story
import OS.SessionManager.WindowManager.Messages exposing (..)
import OS.SessionManager.WindowManager.Models as WM
import Game.Meta.Types.Context exposing (Context(..))
import OS.SessionManager.Types exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , lastTick : Time
    , account : Account.Model
    , activeServer : Servers.Server
    , story : Story.Model
    }


appsConfig : WM.ID -> WM.TargetContext -> Config msg -> Apps.Config msg
appsConfig wId targetContext { toMsg, lastTick, account, activeServer, story } =
    { toMsg = AppMsg targetContext wId >> toMsg
    , lastTick = lastTick
    , account = account
    , activeServer = activeServer
    , story = story
    }
