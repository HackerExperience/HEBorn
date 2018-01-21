module Apps.Config exposing (..)

import Time exposing (Time)
import Apps.Messages exposing (..)
import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Servers.Shared exposing (CId)
import Apps.Explorer.Config as Explorer
import Apps.LogViewer.Config as LogViewer
import Apps.CtrlPanel.Config as CtrlPanel
import Apps.LanViewer.Config as LanViewer
import Apps.Calculator.Config as Calculator
import Apps.TaskManager.Config as TaskManager


type alias Config msg =
    { toMsg : Msg -> msg
    , lastTick : Time
    , account : Account.Model
    , activeServer : Servers.Server
    }


calculatorConfig : Config msg -> Calculator.Config msg
calculatorConfig { toMsg } =
    { toMsg = CalculatorMsg >> toMsg }


taskManConfig : Config msg -> TaskManager.Config msg
taskManConfig { toMsg, activeServer, lastTick } =
    { toMsg = TaskManagerMsg >> toMsg
    , processes = Servers.getProcesses activeServer
    , lastTick = lastTick
    }


logViewerConfig : Config msg -> LogViewer.Config msg
logViewerConfig { toMsg, activeServer } =
    { toMsg = LogViewerMsg >> toMsg
    , logs = Servers.getLogs activeServer
    }


explorerConfig : Config msg -> Explorer.Config msg
explorerConfig { toMsg, activeServer } =
    { toMsg = ExplorerMsg >> toMsg
    , activeServer = activeServer
    }


ctrlPainelConfig : Config msg -> CtrlPanel.Config
ctrlPainelConfig config =
    {}


lanViewerConfig : Config msg -> LanViewer.Config
lanViewerConfig config =
    {}
