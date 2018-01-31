module OS.SessionManager.Config exposing (..)

import ContextMenu
import Html exposing (Attribute)
import Time exposing (Time)
import Utils.Core exposing (..)
import Game.Account.Models as Account
import Game.Account.Bounces.Shared as Bounces
import Game.Account.Finances.Models as Finances
import Game.Account.Notifications.Shared as AccountNotifications
import Game.BackFlix.Models as BackFlix
import Game.Inventory.Models as Inventory
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Meta.Types.Context exposing (Context(..))
import Game.Meta.Types.Requester exposing (Requester)
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Servers.Models as Servers
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Logs.Models as Logs
import Game.Servers.Processes.Models as Processes
import Game.Servers.Shared as Servers exposing (CId, StorageId)
import Game.Storyline.Models as Story
import Game.Storyline.Emails.Contents as Emails
import OS.SessionManager.WindowManager.Config as WindowManager
import OS.SessionManager.Dock.Config as Dock
import OS.SessionManager.Messages exposing (..)
import Apps.Apps as Apps


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , lastTick : Time
    , story : Story.Model
    , isCampaign : Bool
    , servers : Servers.Model
    , account : Account.Model
    , activeServer : ( Servers.CId, Servers.Server )
    , activeContext : Context
    , activeGateway : ( Servers.CId, Servers.Server )
    , inventory : Inventory.Model
    , backFlix : BackFlix.BackFlix
    , endpointCId : Maybe Servers.CId
    , menuAttr : ContextMenuAttribute msg
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
    , onWebLogin : NIP -> Network.IP -> String -> Requester -> msg
    , onFetchUrl : CId -> Network.ID -> Network.IP -> Requester -> msg
    , onReplyEmail : String -> Emails.Content -> msg
    , onActionDone : Apps.App -> Context -> msg
    , onWebLogout : CId -> msg
    }


wmConfig : Servers.SessionId -> Config msg -> WindowManager.Config msg
wmConfig sessionId config =
    { toMsg = WindowManagerMsg sessionId >> config.toMsg
    , lastTick = config.lastTick
    , story = config.story
    , isCampaign = config.isCampaign
    , account = config.account
    , servers = config.servers
    , activeServer = config.activeServer
    , activeGateway = config.activeGateway
    , activeContext = config.activeContext
    , backFlix = config.backFlix
    , inventory = config.inventory
    , batchMsg = config.batchMsg
    , menuAttr = config.menuAttr
    , onNewApp = HandleNewApp >>>> config.toMsg
    , onOpenApp = HandleOpenApp >>> config.toMsg
    , onNewPublicDownload = config.onNewPublicDownload
    , onBankAccountLogin = config.onBankAccountLogin
    , onBankAccountTransfer = config.onBankAccountTransfer
    , onAccountToast = config.onAccountToast
    , onPoliteCrash = config.onPoliteCrash
    , onNewTextFile = config.onNewTextFile
    , onNewDir = config.onNewDir
    , onMoveFile = config.onMoveFile
    , onRenameFile = config.onRenameFile
    , onDeleteFile = config.onDeleteFile
    , onUpdateLog = config.onUpdateLog
    , onEncryptLog = config.onEncryptLog
    , onHideLog = config.onHideLog
    , onDeleteLog = config.onDeleteLog
    , onMotherboardUpdate = config.onMotherboardUpdate
    , onPauseProcess = config.onPauseProcess
    , onResumeProcess = config.onResumeProcess
    , onRemoveProcess = config.onRemoveProcess
    , onSetContext = config.onSetContext
    , onWebLogin = config.onWebLogin
    , onNewBruteforceProcess = config.onNewBruteforceProcess
    , onFetchUrl = config.onFetchUrl
    , onReplyEmail = config.onReplyEmail
    , onActionDone = config.onActionDone
    , onWebLogout = config.onWebLogout
    }


dockConfig : Servers.SessionId -> Config msg -> Dock.Config msg
dockConfig sessionId config =
    { toMsg = DockMsg >> config.toMsg
    , batchMsg = config.batchMsg
    , accountDock = Account.getDock config.account
    , sessionId = sessionId
    , endpointCId = Servers.getEndpointCId <| Tuple.second config.activeServer
    , menuAttr = config.menuAttr
    , wmConfig = wmConfig sessionId config
    }



-- helpers


type alias ContextMenuItens msg =
    List (List ( ContextMenu.Item, msg ))


type alias ContextMenuAttribute msg =
    ContextMenuItens msg -> Attribute msg
