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


emailConfig : Config msg -> Email.Config msg
emailConfig { toMsg, story } =
    { toMsg = EmailMsg >> toMsg
    , emails = Storyline.getEmails story
    }


floatingHeadsConfig : Config msg -> FloatingHeads.Config msg
floatingHeadsConfig { toMsg, story, account } =
    { toMsg = FloatingHeadsMsg >> toMsg
    , emails = Storyline.getEmails story
    , username = Account.getUsername account
    }


bugConfig : Config msg -> Bug.Config msg
bugConfig { toMsg } =
    { toMsg = BugMsg >> toMsg }


serversGearsConfig : Config msg -> ServersGears.Config msg
serversGearsConfig { toMsg, inventory, activeServer } =
    { toMsg = ServersGearsMsg >> toMsg
    , inventory = inventory
    , activeServer = activeServer
    , mobo =
        Servers.getHardware activeServer
            |> Hardware.getMotherboard
    }


browserConfig : Config msg -> Browser.Config msg
browserConfig { toMsg, activeServer } =
    { toMsg = BrowserMsg >> toMsg
    , activeServer = activeServer
    , endpoints = Servers.getEndpoints activeServer
    }


locationPickerConfig : Config msg -> LocationPicker.Config msg
locationPickerConfig { toMsg } =
    { toMsg = LocationPickerMsg >> toMsg }


dbAdminConfig : Config msg -> DBAdmin.Config msg
dbAdminConfig { toMsg, account } =
    { toMsg = DatabaseMsg >> toMsg
    , database = Account.getDatabase account
    }


ctrlPainelConfig : Config msg -> CtrlPanel.Config
ctrlPainelConfig { toMsg } =
    {}


lanViewerConfig : Config msg -> LanViewer.Config
lanViewerConfig { toMsg } =
    {}


connManagerConfig : Config msg -> ConnManager.Config msg
connManagerConfig { toMsg, activeServer } =
    { toMsg = ConnManagerMsg >> toMsg
    , activeServer = activeServer
    }


bounceManConfig : Config msg -> BounceManager.Config msg
bounceManConfig { toMsg, account } =
    { toMsg = BounceManagerMsg >> toMsg
    , bounces = Account.getBounces account
    , database = Account.getDatabase account
    }


financeConfig : Config msg -> Finance.Config msg
financeConfig { toMsg, account } =
    { toMsg = FinanceMsg >> toMsg
    , finances = Account.getFinances account
    }


hebampConfig : Config msg -> Hebamp.Config msg
hebampConfig { toMsg } =
    { toMsg = MusicMsg >> toMsg }


backFlixConfig : Config msg -> BackFlix.Config msg
backFlixConfig { toMsg, backFlix } =
    { toMsg = BackFlixMsg >> toMsg
    , backFlix = backFlix
    }
