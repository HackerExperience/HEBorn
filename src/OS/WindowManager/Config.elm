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
import Apps.VirusPanel.Config as VirusPanel
import Game.Models as Game
import Game.Messages as Game
import Game.Account.Messages as Account
import Game.Account.Models as Account
import Game.Account.Bounces.Messages as Bounces
import Game.Account.Database.Messages as Database
import Game.Account.Finances.Messages as Finances
import Game.Account.Notifications.Shared as AccountNotifications
import Game.Meta.Models as Meta
import Game.Meta.Types.Desktop.Apps as DesktopApp exposing (DesktopApp)
import Game.Meta.Types.Context exposing (Context(..))
import Game.Servers.Messages as Servers
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Shared as Servers exposing (CId, StorageId)
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Hardware.Messages as Hardware
import Game.Servers.Hardware.Models as Hardware
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Processes.Messages as Processes
import Game.Storyline.Messages as Storyline
import Game.Web.Messages as Web
import OS.WindowManager.Messages exposing (..)
import OS.WindowManager.Shared exposing (..)
import OS.WindowManager.Dock.Config as Dock
import OS.WindowManager.Sidebar.Config as Sidebar


type alias Config msg =
    { flags : Flags
    , toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , awaitEvent : String -> msg -> msg
    , gameMsg : Game.Msg -> msg
    , game : Game.Model
    , activeContext : Context
    , activeServer : ( Servers.CId, Servers.Server )
    , activeGateway : ( Servers.CId, Servers.Server )
    , onSetContext : Context -> msg
    , onActionDone : DesktopApp -> Context -> msg
    , onAccountToast : AccountNotifications.Content -> msg
    , menuAttr : List (List ( ContextMenu.Item, msg )) -> Attribute msg
    }



-- NOTE: some apps are collecting active gateway from the config, this is
-- probably wrong, specially for pinned windows, apps shouldn't need active
-- gateway unless they are doing something with gateway's CId/NIP, for those
-- cases, gateway s+hould be collected from a param, not from the config


dragConfig : Config msg -> Draggable.Config WindowId msg
dragConfig config =
    Draggable.customConfig
        [ Draggable.onDragBy (Dragging >> config.toMsg)
        , Draggable.onDragStart (StartDrag >> config.toMsg)
        , Draggable.onDragEnd (config.toMsg StopDrag)
        ]


dockConfig : Config msg -> Dock.Config msg
dockConfig config =
    let
        cid =
            Tuple.first config.activeServer
    in
        { onNewApp = \app -> config.toMsg <| NewApp app Nothing Nothing cid
        , onClickIcon = ClickIcon >> config.toMsg
        , onMinimizeAll = MinimizeAll >> config.toMsg
        , onCloseAll = CloseAll >> config.toMsg
        , onMinimizeWindow = Minimize >> config.toMsg
        , onRestoreWindow = Just >> UpdateFocus >> config.toMsg
        , onCloseWindow = Close >> config.toMsg
        , accountDock = Account.getDock <| accountFromConfig config
        , endpointCId = endpointCIdFromConfig config
        , servers = Game.getServers config.game
        }


backFlixConfig : AppId -> Config msg -> BackFlix.Config msg
backFlixConfig appId config =
    { toMsg = BackFlixMsg >> AppMsg appId >> config.toMsg
    , batchMsg = config.batchMsg
    , logs = Game.getBackFlix config.game
    }


sidebarConfig : Bool -> Config msg -> Sidebar.Config msg
sidebarConfig isFreeplay config =
    let
        ( toMsg, story_ ) =
            if isFreeplay then
                ( MultiplayerSidebarMsg
                , Nothing
                )
            else
                ( CampaingSidebarMsg
                , Just <| Game.getStory config.game
                )
    in
        { toMsg = toMsg >> config.toMsg
        , batchMsg = config.batchMsg
        , story = story_
        }


bounceManagerConfig : AppId -> Config msg -> BounceManager.Config msg
bounceManagerConfig appId config =
    let
        account =
            accountFromConfig config
    in
        { flags = config.flags
        , toMsg = BounceManagerMsg >> AppMsg appId >> config.toMsg
        , batchMsg = config.batchMsg
        , reference = appId
        , bounces = Account.getBounces account
        , database = Account.getDatabase account
        , accountId = Account.getId account
        }


browserConfig :
    AppId
    -> ( CId, Server )
    -> ( CId, Server )
    -> Config msg
    -> Browser.Config msg
browserConfig appId activeServer ( gCId, gServer ) config =
    let
        cid =
            Tuple.first activeServer

        onNewPublicDownload =
            Processes.HandleStartPublicDownload >>>> processes config cid

        onNewBruteforceProcess =
            Processes.HandleStartBruteforce >> processes config gCId

        onBankAccountLogin =
            Finances.HandleBankAccountLogin >>> finances config

        onBankAccountTransfer =
            Finances.HandleBankAccountTransfer >>> finances config
    in
        { flags = config.flags
        , toMsg = BrowserMsg >> AppMsg appId >> config.toMsg
        , batchMsg = config.batchMsg
        , reference = appId
        , activeServer = activeServer
        , activeGateway = config.activeGateway
        , onNewApp = NewApp >>>>> config.toMsg
        , onOpenApp = OpenApp >>> config.toMsg
        , onSetContext = Account.HandleSetContext >> account config
        , onLogin = Web.Login gCId >>>>> web config
        , onLogout = flip (server config) Servers.HandleLogout
        , onNewPublicDownload = onNewPublicDownload
        , onNewBruteforceProcess = onNewBruteforceProcess
        , onBankAccountLogin = onBankAccountLogin
        , onBankAccountTransfer = onBankAccountTransfer
        , menuAttr = config.menuAttr
        }


bugConfig : AppId -> Config msg -> Bug.Config msg
bugConfig appId config =
    { toMsg = BugMsg >> AppMsg appId >> config.toMsg
    , batchMsg = config.batchMsg
    , onAccountToast = config.onAccountToast
    , onPoliteCrash = Account.HandleSignOutAndCrash >> account config
    }


calculatorConfig : AppId -> Config msg -> Calculator.Config msg
calculatorConfig appId config =
    { toMsg = CalculatorMsg >> AppMsg appId >> config.toMsg
    , batchMsg = config.batchMsg
    }


connManagerConfig : AppId -> Config msg -> ConnManager.Config msg
connManagerConfig appId config =
    { toMsg = ConnManagerMsg >> AppMsg appId >> config.toMsg
    , batchMsg = config.batchMsg
    , activeServer = Tuple.second config.activeServer
    }


ctrlPanelConfig : CtrlPanel.Config
ctrlPanelConfig =
    {}


dbAdminConfig : AppId -> Config msg -> DBAdmin.Config msg
dbAdminConfig appId config =
    { toMsg = DBAdminMsg >> AppMsg appId >> config.toMsg
    , batchMsg = config.batchMsg
    , database = Account.getDatabase <| accountFromConfig config
    }


emailConfig : AppId -> ( CId, Server ) -> Config msg -> Email.Config msg
emailConfig appId ( cid, _ ) config =
    { toMsg = EmailMsg >> AppMsg appId >> config.toMsg
    , batchMsg = config.batchMsg
    , story = Game.getStory config.game
    , onOpenApp = flip OpenApp cid >> config.toMsg
    }


explorerConfig : AppId -> ( CId, Server ) -> Config msg -> Explorer.Config msg
explorerConfig appId ( cid, server ) config =
    { toMsg = ExplorerMsg >> AppMsg appId >> config.toMsg
    , batchMsg = config.batchMsg
    , activeServer = server
    , onNewTextFile = Filesystem.HandleNewTextFile >>> filesystem config cid
    , onNewDir = Filesystem.HandleNewDir >>> filesystem config cid
    , onMoveFile = Filesystem.HandleMove >>> filesystem config cid
    , onRenameFile = Filesystem.HandleRename >>> filesystem config cid
    , onDeleteFile = Filesystem.HandleDelete >> filesystem config cid
    , menuAttr = config.menuAttr
    }


financeConfig : AppId -> Config msg -> Finance.Config msg
financeConfig appId config =
    { toMsg = FinanceMsg >> AppMsg appId >> config.toMsg
    , finances = Account.getFinances <| accountFromConfig config
    , batchMsg = config.batchMsg
    }


floatingHeadsConfig :
    WindowId
    -> AppId
    -> ( CId, Server )
    -> Config msg
    -> FloatingHeads.Config msg
floatingHeadsConfig windowId appId ( gCid, _ ) config =
    { toMsg = FloatingHeadsMsg >> AppMsg appId >> config.toMsg
    , batchMsg = config.batchMsg
    , reference = appId
    , story = Game.getStory config.game
    , username = Account.getUsername <| accountFromConfig config
    , onReply = Storyline.HandleReply >>> storyline config
    , onCloseApp = config.toMsg <| Close windowId
    , onOpenApp = flip OpenApp gCid >> config.toMsg
    , draggable = draggable windowId config
    }


hebampConfig : WindowId -> AppId -> Config msg -> Hebamp.Config msg
hebampConfig windowId appId config =
    { toMsg = HebampMsg >> AppMsg appId >> config.toMsg
    , batchMsg = config.batchMsg
    , reference = appId
    , onCloseApp = config.toMsg <| Close windowId
    , draggable = draggable windowId config
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


logViewerConfig : AppId -> ( CId, Server ) -> Config msg -> LogViewer.Config msg
logViewerConfig appId ( cid, server ) config =
    { toMsg = LogViewerMsg >> AppMsg appId >> config.toMsg
    , logs = Servers.getLogs server
    , batchMsg = config.batchMsg
    , onUpdate = Logs.HandleUpdateContent >>> logs config cid
    , onEncrypt = Logs.HandleEncrypt >> logs config cid
    , onHide = Logs.HandleHide >> logs config cid
    , onDelete = Logs.HandleDelete >> logs config cid
    , menuAttr = config.menuAttr
    }


serversGearsConfig :
    AppId
    -> ( CId, Server )
    -> Config msg
    -> ServersGears.Config msg
serversGearsConfig appId ( cid, server ) config =
    { toMsg = ServersGearsMsg >> AppMsg appId >> config.toMsg
    , inventory = Game.getInventory config.game
    , activeServer = server
    , mobo = Hardware.getMotherboard <| Servers.getHardware server
    , batchMsg = config.batchMsg
    , onUpdate = Hardware.HandleMotherboardUpdate >> hardware config cid
    }


taskManagerConfig :
    AppId
    -> ( CId, Server )
    -> Config msg
    -> TaskManager.Config msg
taskManagerConfig appId ( cid, server ) config =
    { toMsg = TaskManagerMsg >> AppMsg appId >> config.toMsg
    , processes = Servers.getProcesses server
    , lastTick = lastTickFromConfig config
    , batchMsg = config.batchMsg
    , onPause = Processes.HandlePause >> processes config cid
    , onResume = Processes.HandleResume >> processes config cid
    , onRemove = Processes.HandleRemove >> processes config cid
    , menuAttr = config.menuAttr
    }


virusPanelConfig :
    AppId
    -> ( CId, Server )
    -> Config msg
    -> VirusPanel.Config msg
virusPanelConfig appId activeGateway config =
    let
        ( cid, server ) =
            activeGateway

        account =
            accountFromConfig config
    in
        { toMsg = VirusPanelMsg >> AppMsg appId >> config.toMsg
        , batchMsg = config.batchMsg
        , flags = config.flags
        , database = Account.getDatabase account
        , processes = Servers.getProcesses server
        , finances = Account.getFinances account
        , bounces = Account.getBounces account
        , activeGatewayCId = cid
        , accountId = Account.getId account
        }



-- dispatch helpers


account : Config msg -> Account.Msg -> msg
account config =
    Game.AccountMsg >> config.gameMsg


bounces : Config msg -> Bounces.Msg -> msg
bounces config =
    Account.BouncesMsg >> account config


database : Config msg -> Database.Msg -> msg
database config =
    Account.DatabaseMsg >> account config


finances : Config msg -> Finances.Msg -> msg
finances config =
    Account.FinancesMsg >> account config


servers : Config msg -> Servers.Msg -> msg
servers config =
    Game.ServersMsg >> config.gameMsg


server : Config msg -> CId -> Servers.ServerMsg -> msg
server config cid =
    Servers.ServerMsg cid >> servers config


filesystem : Config msg -> CId -> Filesystem.Msg -> Servers.StorageId -> msg
filesystem config cid msg storageId =
    server config cid <| Servers.FilesystemMsg storageId msg


hardware : Config msg -> CId -> Hardware.Msg -> msg
hardware config cid =
    Servers.HardwareMsg >> server config cid


logs : Config msg -> CId -> Logs.Msg -> msg
logs config cid =
    Servers.LogsMsg >> server config cid


processes : Config msg -> CId -> Processes.Msg -> msg
processes config cid =
    Servers.ProcessesMsg >> server config cid


web : Config msg -> Web.Msg -> msg
web config =
    Game.WebMsg >> config.gameMsg


storyline : Config msg -> Storyline.Msg -> msg
storyline config =
    Game.StoryMsg >> config.gameMsg



-- other helpers


serversFromConfig : Config msg -> Servers.Model
serversFromConfig { game } =
    Game.getServers game


isCampaignFromConfig : Config msg -> Bool
isCampaignFromConfig { activeServer } =
    activeServer
        |> Tuple.second
        |> Servers.getType
        |> (==) Servers.DesktopCampaign


endpointCIdFromConfig : Config msg -> Maybe CId
endpointCIdFromConfig { activeGateway } =
    activeGateway
        |> Tuple.second
        |> Servers.getEndpointCId


accountFromConfig : Config msg -> Account.Model
accountFromConfig { game } =
    Game.getAccount game


lastTickFromConfig : Config msg -> Time
lastTickFromConfig { game } =
    game
        |> Game.getMeta
        |> Meta.getLastTick


draggable : WindowId -> Config msg -> Attribute msg
draggable windowId config =
    Draggable.mouseTrigger windowId (DragMsg >> config.toMsg)


windowMenu : Config msg -> WindowId -> Attribute msg
windowMenu config id =
    [ ( ContextMenu.item "Minimize", config.toMsg <| Minimize id )
    , ( ContextMenu.item "Close", config.toMsg <| Close id )
    ]
        |> List.singleton
        |> config.menuAttr
