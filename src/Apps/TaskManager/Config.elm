module Apps.TaskManager.Config exposing (..)

import Time exposing (Time)
import Game.Servers.Shared exposing (CId)
import Game.Servers.Processes.Models as Processes
import Apps.TaskManager.Messages exposing (..)
import Apps.TaskManager.Menu.Config as Menu


type alias Config msg =
    { toMsg : Msg -> msg
    , processes : Processes.Model
    , lastTick : Time
    , batchMsg : List msg -> msg
    , onPauseProcess : Processes.ID -> msg
    , onResumeProcess : Processes.ID -> msg
    , onRemoveProcess : Processes.ID -> msg
    }


menuConfig : Config msg -> Menu.Config msg
menuConfig config =
    { toMsg = MenuMsg >> config.toMsg
    , batchMsg = config.batchMsg
    , onPauseProcess = config.onPauseProcess
    , onResumeProcess = config.onResumeProcess
    , onRemoveProcess = config.onRemoveProcess
    }
