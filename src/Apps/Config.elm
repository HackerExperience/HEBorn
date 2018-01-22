module Apps.Config exposing (..)

import Time exposing (Time)
import Apps.Messages exposing (..)
import Game.Account.Models as Account
import Game.BackFlix.Models as BackFlix
import Game.Inventory.Models as Inventory
import Game.Servers.Models as Servers
import Game.Servers.Shared exposing (CId)
import Game.Storyline.Models as Storyline
import Game.Servers.Hardware.Models as Hardware
import Apps.Bug.Config as Bug
import Apps.Email.Config as Email
import Apps.Hebamp.Config as Hebamp
import Apps.DBAdmin.Config as DBAdmin
import Apps.Browser.Config as Browser
import Apps.Finance.Config as Finance
import Apps.Explorer.Config as Explorer
import Apps.BackFlix.Config as BackFlix
import Apps.LogViewer.Config as LogViewer
import Apps.CtrlPanel.Config as CtrlPanel
import Apps.LanViewer.Config as LanViewer
import Apps.Calculator.Config as Calculator
import Apps.ConnManager.Config as ConnManager
import Apps.TaskManager.Config as TaskManager
import Apps.ServersGears.Config as ServersGears
import Apps.FloatingHeads.Config as FloatingHeads
import Apps.BounceManager.Config as BounceManager
import Apps.LocationPicker.Config as LocationPicker


type alias Config msg =
    { toMsg : Msg -> msg
    , lastTick : Time
    , story : Storyline.Model
    , account : Account.Model
    , inventory : Inventory.Model
    , activeServer : Servers.Server
    , backFlix : BackFlix.BackFlix
    , batchMsg : List msg -> msg
    }


calculatorConfig : Config msg -> Calculator.Config msg
calculatorConfig config =
    { toMsg = CalculatorMsg >> config.toMsg
    , batchMsg = config.batchMsg
    }


taskManConfig : Config msg -> TaskManager.Config msg
taskManConfig config =
    { toMsg = TaskManagerMsg >> config.toMsg
    , processes = Servers.getProcesses config.activeServer
    , lastTick = config.lastTick
    , batchMsg = config.batchMsg
    }


logViewerConfig : Config msg -> LogViewer.Config msg
logViewerConfig config =
    { toMsg = LogViewerMsg >> config.toMsg
    , logs = Servers.getLogs config.activeServer
    , batchMsg = config.batchMsg
    }


explorerConfig : Config msg -> Explorer.Config msg
explorerConfig config =
    { toMsg = ExplorerMsg >> config.toMsg
    , activeServer = config.activeServer
    , batchMsg = config.batchMsg
    }


emailConfig : Config msg -> Email.Config msg
emailConfig config =
    { toMsg = EmailMsg >> config.toMsg
    , emails = Storyline.getEmails config.story
    , batchMsg = config.batchMsg
    }


floatingHeadsConfig : Config msg -> FloatingHeads.Config msg
floatingHeadsConfig config =
    { toMsg = FloatingHeadsMsg >> config.toMsg
    , emails = Storyline.getEmails config.story
    , username = Account.getUsername config.account
    , batchMsg = config.batchMsg
    }


bugConfig : Config msg -> Bug.Config msg
bugConfig config =
    { toMsg = BugMsg >> config.toMsg
    , batchMsg = config.batchMsg
    }


serversGearsConfig : Config msg -> ServersGears.Config msg
serversGearsConfig config =
    { toMsg = ServersGearsMsg >> config.toMsg
    , inventory = config.inventory
    , activeServer = config.activeServer
    , mobo =
        Servers.getHardware config.activeServer
            |> Hardware.getMotherboard
    , batchMsg = config.batchMsg
    }


browserConfig : Config msg -> Browser.Config msg
browserConfig config =
    { toMsg = BrowserMsg >> config.toMsg
    , activeServer = config.activeServer
    , endpoints = Servers.getEndpoints config.activeServer
    , batchMsg = config.batchMsg
    }


locationPickerConfig : Config msg -> LocationPicker.Config msg
locationPickerConfig config =
    { toMsg = LocationPickerMsg >> config.toMsg
    , batchMsg = config.batchMsg
    }


dbAdminConfig : Config msg -> DBAdmin.Config msg
dbAdminConfig config =
    { toMsg = DatabaseMsg >> config.toMsg
    , database = Account.getDatabase config.account
    , batchMsg = config.batchMsg
    }


ctrlPainelConfig : Config msg -> CtrlPanel.Config
ctrlPainelConfig { toMsg } =
    {}


lanViewerConfig : Config msg -> LanViewer.Config
lanViewerConfig { toMsg } =
    {}


connManagerConfig : Config msg -> ConnManager.Config msg
connManagerConfig config =
    { toMsg = ConnManagerMsg >> config.toMsg
    , activeServer = config.activeServer
    , batchMsg = config.batchMsg
    }


bounceManConfig : Config msg -> BounceManager.Config msg
bounceManConfig config =
    { toMsg = BounceManagerMsg >> config.toMsg
    , bounces = Account.getBounces config.account
    , database = Account.getDatabase config.account
    , batchMsg = config.batchMsg
    }


financeConfig : Config msg -> Finance.Config msg
financeConfig config =
    { toMsg = FinanceMsg >> config.toMsg
    , finances = Account.getFinances config.account
    , batchMsg = config.batchMsg
    }


hebampConfig : Config msg -> Hebamp.Config msg
hebampConfig config =
    { toMsg = MusicMsg >> config.toMsg
    , batchMsg = config.batchMsg
    }


backFlixConfig : Config msg -> BackFlix.Config msg
backFlixConfig config =
    { toMsg = BackFlixMsg >> config.toMsg
    , backFlix = config.backFlix
    , batchMsg = config.batchMsg
    }
