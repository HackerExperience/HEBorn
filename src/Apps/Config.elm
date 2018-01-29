module Apps.Config exposing (..)

import ContextMenu
import Html exposing (Attribute)
import Time exposing (Time)
import Game.Account.Models as Account
import Game.Account.Finances.Models as Finances
import Game.Account.Notifications.Shared as AccountNotifications
import Game.BackFlix.Models as BackFlix
import Game.Inventory.Models as Inventory
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Meta.Types.Context exposing (Context)
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Meta.Types.Requester exposing (Requester)
import Game.Servers.Models as Servers
import Game.Servers.Shared exposing (CId, StorageId)
import Game.Servers.Hardware.Models as Hardware
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Logs.Models as Logs
import Game.Servers.Processes.Models as Processes
import Game.Storyline.Models as Storyline
import Game.Storyline.Emails.Contents as Emails
import Apps.Apps as Apps
import Apps.Messages exposing (..)
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
    , activeServer : ( CId, Servers.Server )
    , activeGateway : ( CId, Servers.Server )
    , backFlix : BackFlix.BackFlix
    , batchMsg : List msg -> msg
    , draggable : Attribute msg
    , menuAttr : ContextMenuAttribute msg
    , windowMenu : Attribute msg
    , onNewApp : Maybe Context -> Maybe Apps.AppParams -> Apps.App -> msg
    , onOpenApp : Maybe Context -> Apps.AppParams -> msg
    , onNewPublicDownload : NIP -> StorageId -> Filesystem.FileEntry -> msg
    , onBankAccountLogin : Finances.BankLoginRequest -> Requester -> msg
    , onBankAccountTransfer : Finances.BankTransferRequest -> Requester -> msg
    , onAccountToast : AccountNotifications.Content -> msg
    , onPoliteCrash : ( String, String ) -> msg
    , onNewTextFile : StorageId -> Filesystem.Path -> Filesystem.Name -> msg
    , onNewDir : StorageId -> Filesystem.Path -> Filesystem.Name -> msg
    , onMoveFile : StorageId -> Filesystem.Id -> Filesystem.Path -> msg
    , onRenameFile : StorageId -> Filesystem.Id -> Filesystem.Name -> msg
    , onDeleteFile : StorageId -> Filesystem.Id -> msg
    , onUpdateLog : Logs.ID -> String -> msg
    , onEncryptLog : Logs.ID -> msg
    , onHideLog : Logs.ID -> msg
    , onDeleteLog : Logs.ID -> msg
    , onMotherboardUpdate : Motherboard -> msg
    , onPauseProcess : Processes.ID -> msg
    , onResumeProcess : Processes.ID -> msg
    , onRemoveProcess : Processes.ID -> msg
    , onSetContext : Context -> msg
    , onNewBruteforceProcess : CId -> Network.IP -> msg
    , onWebLogin : NIP -> Network.IP -> String -> Requester -> msg
    , onFetchUrl : CId -> Network.ID -> Network.IP -> Requester -> msg
    , onReplyEmail : String -> Emails.Content -> msg
    , onCloseApp : msg
    , onWebLogout : CId -> msg
    }


calculatorConfig : Config msg -> Calculator.Config msg
calculatorConfig config =
    { toMsg = CalculatorMsg >> config.toMsg
    , batchMsg = config.batchMsg
    }


taskManConfig : Config msg -> TaskManager.Config msg
taskManConfig config =
    { toMsg = TaskManagerMsg >> config.toMsg
    , processes =
        config.activeServer
            |> Tuple.second
            |> Servers.getProcesses
    , lastTick = config.lastTick
    , batchMsg = config.batchMsg
    , onPauseProcess = config.onPauseProcess
    , onResumeProcess = config.onResumeProcess
    , onRemoveProcess = config.onRemoveProcess
    }


logViewerConfig : Config msg -> LogViewer.Config msg
logViewerConfig config =
    { toMsg = LogViewerMsg >> config.toMsg
    , logs =
        config.activeServer
            |> Tuple.second
            |> Servers.getLogs
    , batchMsg = config.batchMsg
    , onUpdateLog = config.onUpdateLog
    , onEncryptLog = config.onEncryptLog
    , onHideLog = config.onHideLog
    , onDeleteLog = config.onDeleteLog
    }


explorerConfig : Config msg -> Explorer.Config msg
explorerConfig config =
    { toMsg = ExplorerMsg >> config.toMsg
    , batchMsg = config.batchMsg
    , activeServer =
        config.activeServer
            |> Tuple.second
    , menuAttr = config.menuAttr
    , onNewTextFile = config.onNewTextFile
    , onNewDir = config.onNewDir
    , onMoveFile = config.onMoveFile
    , onRenameFile = config.onRenameFile
    , onDeleteFile = config.onDeleteFile
    }


emailConfig : Config msg -> Email.Config msg
emailConfig config =
    { toMsg = EmailMsg >> config.toMsg
    , emails = Storyline.getEmails config.story
    , batchMsg = config.batchMsg
    , onOpenApp = config.onOpenApp
    }


floatingHeadsConfig : Config msg -> FloatingHeads.Config msg
floatingHeadsConfig config =
    { toMsg = FloatingHeadsMsg >> config.toMsg
    , batchMsg = config.batchMsg
    , emails = Storyline.getEmails config.story
    , username = Account.getUsername config.account
    , onReplyEmail = config.onReplyEmail
    , onCloseApp = config.onCloseApp
    , onOpenApp = config.onOpenApp
    , draggable = config.draggable
    }


bugConfig : Config msg -> Bug.Config msg
bugConfig config =
    { toMsg = BugMsg >> config.toMsg
    , batchMsg = config.batchMsg
    , onAccountToast = config.onAccountToast
    , onPoliteCrash = config.onPoliteCrash
    }


serversGearsConfig : Config msg -> ServersGears.Config msg
serversGearsConfig config =
    { toMsg = ServersGearsMsg >> config.toMsg
    , inventory = config.inventory
    , activeServer = Tuple.second config.activeServer
    , mobo =
        config.activeServer
            |> Tuple.second
            |> Servers.getHardware
            |> Hardware.getMotherboard
    , batchMsg = config.batchMsg
    , onMotherboardUpdate = config.onMotherboardUpdate
    }


browserConfig : Config msg -> Browser.Config msg
browserConfig config =
    { toMsg = BrowserMsg >> config.toMsg
    , batchMsg = config.batchMsg
    , activeServer = Tuple.second config.activeServer
    , activeGateway = Tuple.second config.activeGateway
    , endpoints =
        config.activeGateway
            |> Tuple.second
            |> Servers.getEndpoints
            |> Maybe.withDefault []
    , menuAttr = config.menuAttr
    , onNewApp = config.onNewApp
    , onOpenApp = config.onOpenApp
    , onNewPublicDownload = config.onNewPublicDownload
    , onBankAccountLogin = config.onBankAccountLogin
    , onBankAccountTransfer = config.onBankAccountTransfer
    , onSetContext = config.onSetContext
    , onNewBruteforceProcess =
        config.activeServer
            |> Tuple.first
            |> config.onNewBruteforceProcess
    , onWebLogin = config.onWebLogin
    , onFetchUrl =
        config.activeServer
            |> Tuple.first
            |> config.onFetchUrl
    , onWebLogout = config.onWebLogout
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
    , activeServer = Tuple.second config.activeServer
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
    , onCloseApp = config.onCloseApp
    , draggable = config.draggable
    , windowMenu = config.windowMenu
    }


backFlixConfig : Config msg -> BackFlix.Config msg
backFlixConfig config =
    { toMsg = BackFlixMsg >> config.toMsg
    , backFlix = config.backFlix
    , batchMsg = config.batchMsg
    }



-- helpers


type alias ContextMenuItens msg =
    List (List ( ContextMenu.Item, msg ))


type alias ContextMenuAttribute msg =
    ContextMenuItens msg -> Attribute msg
