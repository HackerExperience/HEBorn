module OS.SessionManager.WindowManager.Config exposing (..)

import Apps.Config as Apps
import OS.SessionManager.WindowManager.Messages exposing (..)
import OS.SessionManager.WindowManager.Models as WM
import Game.Meta.Types.Context exposing (Context(..))
import OS.SessionManager.Types exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    }


appsConfig : WM.ID -> WM.TargetContext -> Config msg -> Apps.Config msg
appsConfig wId targetContext config =
    { toMsg = AppMsg targetContext wId >> config.toMsg
    }
