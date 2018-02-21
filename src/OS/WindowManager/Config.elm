module OS.WindowManager.Config exposing (..)

import Time exposing (Time)
import Html exposing (Attribute)
import ContextMenu
import Draggable
import Draggable.Events as Draggable
import Utils.Core exposing (..)
import Core.Flags exposing (Flags)
import Apps.BackFlix.Config as BackFlix
import Apps.BounceManager.Config as BounceManager
import Apps.Browser.Config as Browser
import Apps.Bug.Config as Bug
import Apps.Calculator.Config as Calculator
import Apps.Calculator.Messages as Calculator
import Apps.ConnManager.Config as ConnManager
import Apps.CtrlPanel.Config as CtrlPanel
import Apps.DBAdmin.Config as DBAdmin
import Apps.Email.Config as Email
import Apps.Explorer.Config as Explorer
import Apps.Finance.Config as Finance
import Apps.FloatingHeads.Config as FloatingHeads
import Apps.Hebamp.Config as Hebamp
import Apps.LanViewer.Config as LanViewer
import Apps.LocationPicker.Config as LocationPicker
import Apps.LogViewer.Config as LogViewer
import Apps.ServersGears.Config as ServersGears
import Apps.TaskManager.Config as TaskManager
import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)
import Game.Account.Models as Account
import Game.Account.Bounces.Shared as Bounces
import Game.Account.Finances.Models as Finances
import Game.Account.Notifications.Shared as AccountNotifications
import Game.BackFlix.Models as BackFlix
import Game.Inventory.Models as Inventory
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Meta.Types.Context exposing (Context(..))
import Game.Meta.Types.Apps.Desktop exposing (Requester)
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Shared as Servers exposing (CId, StorageId)
import Game.Servers.Hardware.Models as Hardware
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Logs.Models as Logs
import Game.Servers.Processes.Models as Processes
import Game.Storyline.Models as Storyline
import Game.Storyline.Shared as Storyline
import OS.WindowManager.Dock.Config as Dock
import OS.WindowManager.Messages exposing (..)
import OS.WindowManager.Shared exposing (..)


type alias Config msg =
    { flags : Flags
    , toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , onSetBounce : Maybe Bounces.ID -> msg
    , onNewPublicDownload : NIP -> StorageId -> Filesystem.FileEntry -> msg
    , onBankAccountLogin : Finances.BankLoginRequest -> Requester -> msg
    , onBankAccountTransfer : Finances.BankTransferRequest -> Requester -> msg
    , onAccountToast : AccountNotifications.Content -> msg
    , onPoliteCrash : ( String, String ) -> msg
    , onNewTextFile : CId -> StorageId -> Filesystem.Path -> Filesystem.Name -> msg
    , onNewDir : CId -> StorageId -> Filesystem.Path -> Filesystem.Name -> msg
    , onMoveFile : CId -> StorageId -> Filesystem.Id -> Filesystem.Path -> msg
    , onRenameFile : CId -> StorageId -> Filesystem.Id -> Filesystem.Name -> msg
    , onDeleteFile : CId -> StorageId -> Filesystem.Id -> msg
    , onUpdateLog : CId -> Logs.ID -> String -> msg
    , onEncryptLog : CId -> Logs.ID -> msg
    , onHideLog : CId -> Logs.ID -> msg
    , onDeleteLog : CId -> Logs.ID -> msg
    , onMotherboardUpdate : CId -> Motherboard -> msg
    , onPauseProcess : CId -> Processes.ID -> msg
    , onResumeProcess : CId -> Processes.ID -> msg
    , onRemoveProcess : CId -> Processes.ID -> msg
    , onSetContext : Context -> msg
    , onNewBruteforceProcess : CId -> Network.IP -> msg
    , onWebLogin : CId -> NIP -> Network.IP -> String -> Requester -> msg
    , onFetchUrl : CId -> Network.ID -> Network.IP -> Requester -> msg
    , onReplyEmail : String -> Storyline.Reply -> msg
    , onActionDone : DesktopApp -> Context -> msg
    , onWebLogout : CId -> msg
    , lastTick : Time
    , isCampaign : Bool
    , activeContext : Context
    , endpointCId : Maybe Servers.CId
    , activeGateway : ( Servers.CId, Servers.Server )
    , activeServer : ( Servers.CId, Servers.Server )
    , story : Storyline.Model
    , servers : Servers.Model
    , account : Account.Model
    , inventory : Inventory.Model
    , backFlix : BackFlix.BackFlix
    , accountId : String
    , menuAttr : List (List ( ContextMenu.Item, msg )) -> Attribute msg
    }



-- NOTE: some apps are collecting active gateway from the config, this is
-- probably wrong, specially for pinned windows, apps shouldn't need active
-- gateway unless they are doing something with gateway's CId/NIP, for those
-- cases, gateway should be collected from a param, not from the config


dragConfig : Config msg -> Draggable.Config WindowId msg
dragConfig config =
    Draggable.customConfig
        [ Draggable.onDragBy (Dragging >> config.toMsg)
        , Draggable.onDragStart (StartDrag >> config.toMsg)
        , Draggable.onDragEnd (config.toMsg StopDrag)
        ]


dockConfig : Config msg -> Dock.Config msg
dockConfig config =
    { onNewApp =
        \app ->
            config.toMsg <|
                NewApp app Nothing Nothing (Tuple.first config.activeServer)
    , onClickIcon = ClickIcon >> config.toMsg
    , onMinimizeAll = MinimizeAll >> config.toMsg
    , onCloseAll = CloseAll >> config.toMsg
    , onMinimizeWindow = Minimize >> config.toMsg
    , onRestoreWindow = Just >> UpdateFocus >> config.toMsg
    , onCloseWindow = Close >> config.toMsg
    , accountDock = Account.getDock config.account
    , endpointCId = config.endpointCId
    , servers = config.servers
    }


backFlixConfig : AppId -> Config msg -> BackFlix.Config msg
backFlixConfig appId config =
    { toMsg = BackFlixMsg >> AppMsg appId >> config.toMsg
    , backFlix = config.backFlix
    , batchMsg = config.batchMsg
    }


bounceManagerConfig : AppId -> Config msg -> BounceManager.Config msg
bounceManagerConfig appId config =
    { flags = config.flags
    , toMsg = BounceManagerMsg >> AppMsg appId >> config.toMsg
    , batchMsg = config.batchMsg
    , reference = appId
    , bounces = Account.getBounces config.account
    , database = Account.getDatabase config.account
    , accountId = config.accountId
    }


browserConfig : AppId -> CId -> Server -> Config msg -> Browser.Config msg
browserConfig appId cid server config =
    { flags = config.flags
    , toMsg = BrowserMsg >> AppMsg appId >> config.toMsg
    , batchMsg = config.batchMsg
    , activeServer = ( cid, server )
    , activeGateway = Tuple.second config.activeGateway
    , reference = appId
    , endpointCId = config.endpointCId
    , endpoints =
        config.activeGateway
            |> Tuple.second
            |> Servers.getEndpoints
            |> Maybe.withDefault []
    , onNewApp =
        \app context params ->
            case config.endpointCId of
                Just cid ->
                    config.toMsg <| NewApp app context params cid

                Nothing ->
                    config.batchMsg []
    , onOpenApp =
        OpenApp >>> config.toMsg
    , onNewPublicDownload = config.onNewPublicDownload
    , onBankAccountLogin = config.onBankAccountLogin
    , onBankAccountTransfer = config.onBankAccountTransfer
    , onSetContext = config.onSetContext
    , onNewBruteforceProcess =
        config.activeServer
            |> Tuple.first
            |> config.onNewBruteforceProcess
    , onWebLogin = config.onWebLogin cid
    , onFetchUrl =
        config.activeServer
            |> Tuple.first
            |> config.onFetchUrl
    , onWebLogout = config.onWebLogout
    , menuAttr = config.menuAttr
    }


bugConfig : AppId -> Config msg -> Bug.Config msg
bugConfig appId config =
    { toMsg = BugMsg >> AppMsg appId >> config.toMsg
    , batchMsg = config.batchMsg
    , onAccountToast = config.onAccountToast
    , onPoliteCrash = config.onPoliteCrash
    }


calculatorConfig : AppId -> Config msg -> Calculator.Config msg
calculatorConfig appId config =
    { toMsg = CalculatorMsg >> AppMsg appId >> config.toMsg
    , batchMsg = config.batchMsg
    }


connManagerConfig : AppId -> Config msg -> ConnManager.Config msg
connManagerConfig appId config =
    { toMsg = ConnManagerMsg >> AppMsg appId >> config.toMsg
    , activeServer = Tuple.second config.activeServer
    , batchMsg = config.batchMsg
    }


ctrlPanelConfig : CtrlPanel.Config
ctrlPanelConfig =
    {}


dbAdminConfig : AppId -> Config msg -> DBAdmin.Config msg
dbAdminConfig appId config =
    { toMsg = DBAdminMsg >> AppMsg appId >> config.toMsg
    , database = Account.getDatabase config.account
    , batchMsg = config.batchMsg
    }


emailConfig : AppId -> CId -> Config msg -> Email.Config msg
emailConfig appId cid config =
    { toMsg = EmailMsg >> AppMsg appId >> config.toMsg
    , story = config.story
    , batchMsg = config.batchMsg
    , onOpenApp = OpenApp cid >> config.toMsg
    }


explorerConfig : AppId -> CId -> Server -> Config msg -> Explorer.Config msg
explorerConfig appId cid server config =
    { toMsg = ExplorerMsg >> AppMsg appId >> config.toMsg
    , batchMsg = config.batchMsg
    , activeServer = server
    , onNewTextFile = config.onNewTextFile cid
    , onNewDir = config.onNewDir cid
    , onMoveFile = config.onMoveFile cid
    , onRenameFile = config.onRenameFile cid
    , onDeleteFile = config.onDeleteFile cid
    , menuAttr = config.menuAttr
    }


financeConfig : AppId -> Config msg -> Finance.Config msg
financeConfig appId config =
    { toMsg = FinanceMsg >> AppMsg appId >> config.toMsg
    , finances = Account.getFinances config.account
    , batchMsg = config.batchMsg
    }


floatingHeadsConfig :
    WindowId
    -> AppId
    -> CId
    -> Config msg
    -> FloatingHeads.Config msg
floatingHeadsConfig windowId appId cid config =
    { toMsg = FloatingHeadsMsg >> AppMsg appId >> config.toMsg
    , batchMsg = config.batchMsg
    , reference = appId
    , story = config.story
    , username = Account.getUsername config.account
    , onReplyEmail = config.onReplyEmail
    , onCloseApp = config.toMsg <| Close windowId
    , onOpenApp = OpenApp cid >> config.toMsg
    , draggable = draggableHelper windowId config
    }


hebampConfig : WindowId -> AppId -> Config msg -> Hebamp.Config msg
hebampConfig windowId appId config =
    { toMsg = HebampMsg >> AppMsg appId >> config.toMsg
    , batchMsg = config.batchMsg
    , reference = appId
    , onCloseApp = config.toMsg <| Close windowId
    , draggable = draggableHelper windowId config
    , windowMenu = windowMenu config windowId
    }


lanViewerConfig : LanViewer.Config
lanViewerConfig =
    {}


locationPickerConfig : AppId -> Config msg -> LocationPicker.Config msg
locationPickerConfig appId config =
    { toMsg = LocationPickerMsg >> AppMsg appId >> config.toMsg
    , batchMsg = config.batchMsg
    }


logViewerConfig : AppId -> CId -> Server -> Config msg -> LogViewer.Config msg
logViewerConfig appId cid server config =
    { toMsg = LogViewerMsg >> AppMsg appId >> config.toMsg
    , logs = Servers.getLogs server
    , batchMsg = config.batchMsg
    , onUpdateLog = config.onUpdateLog cid
    , onEncryptLog = config.onEncryptLog cid
    , onHideLog = config.onHideLog cid
    , onDeleteLog = config.onDeleteLog cid
    , menuAttr = config.menuAttr
    }


serversGearsConfig :
    AppId
    -> CId
    -> Server
    -> Config msg
    -> ServersGears.Config msg
serversGearsConfig appId cid server config =
    { toMsg = ServersGearsMsg >> AppMsg appId >> config.toMsg
    , inventory = config.inventory
    , activeServer = server
    , mobo = Hardware.getMotherboard <| Servers.getHardware server
    , batchMsg = config.batchMsg
    , onMotherboardUpdate = config.onMotherboardUpdate cid
    }


taskManagerConfig :
    AppId
    -> CId
    -> Server
    -> Config msg
    -> TaskManager.Config msg
taskManagerConfig appId cid server config =
    { toMsg = TaskManagerMsg >> AppMsg appId >> config.toMsg
    , processes = Servers.getProcesses server
    , lastTick = config.lastTick
    , batchMsg = config.batchMsg
    , onPauseProcess = config.onPauseProcess cid
    , onResumeProcess = config.onResumeProcess cid
    , onRemoveProcess = config.onRemoveProcess cid
    , menuAttr = config.menuAttr
    }


draggableHelper : WindowId -> Config msg -> Attribute msg
draggableHelper windowId config =
    Draggable.mouseTrigger windowId (DragMsg >> config.toMsg)


windowMenu : Config msg -> WindowId -> Attribute msg
windowMenu config id =
    [ ( ContextMenu.item "Minimize", config.toMsg <| Minimize id )
    , ( ContextMenu.item "Close", config.toMsg <| Close id )
    ]
        |> List.singleton
        |> config.menuAttr
