module Apps.Config exposing (..)

import Time exposing (Time)
import Apps.Messages exposing (..)
import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Servers.Shared exposing (CId)
import Apps.CtrlPanel.Config as CtrlPanel
import Apps.LanViewer.Config as LanViewer
import Apps.Calculator.Config as Calculator
import Apps.TaskManager.Config as TaskManager


type alias Config msg =
    { toMsg : Msg -> msg
    , activeCId : CId
    , account : Account.Model
    , server : Servers.Server
    , lastTick : Time
    }


calculatorConfig : Config msg -> Calculator.Config msg
calculatorConfig config =
    { toMsg = CalculatorMsg >> config.toMsg }


taskManConfig : Config msg -> TaskManager.Config msg
taskManConfig config =
    { toMsg = TaskManagerMsg >> config.toMsg
    , activeCId = config.activeCId
    , processes = Servers.getProcesses config.server
    , lastTick = config.lastTick
    }


logViewerConfig : Config msg -> LogViewer.Config msg
logViewerConfig config =
    { toMsg = LogViewerMsg >> config.toMsg
    , activeCId = config.activeCId
    , logs = Servers.getLogs config.server
    }


explorerConfig : Config msg -> Explorer.Config msg
explorerConfig config =
    { toMsg = ExplorerMsg >> config.toMsg
    , activeCId = config.activeCId
    }


ctrlPainelConfig : Config msg -> CtrlPanel.Config
ctrlPainelConfig config =
    {}


lanViewerConfig : Config msg -> LanViewer.Config
lanViewerConfig config =
    {}
