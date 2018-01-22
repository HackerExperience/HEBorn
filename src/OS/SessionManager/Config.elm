module OS.SessionManager.Config exposing (..)

import Time exposing (Time)
import Utils.Core exposing (..)
import Game.Account.Models as Account
import Game.Account.Bounces.Shared as Bounces
import Game.Account.Finances.Models as Finances
import Game.Account.Notifications.Shared as AccountNotifications
import Game.BackFlix.Models as BackFlix
import Game.Inventory.Models as Inventory
import Game.Meta.Types.Context exposing (Context(..))
import Game.Meta.Types.Requester exposing (Requester)
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Servers.Models as Servers
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Notifications.Shared as ServersNotifications
import Game.Servers.Processes.Requests.Download as Download
import Game.Servers.Shared as Servers
import Game.Storyline.Models as Story
import OS.SessionManager.WindowManager.Config as WindowManager
import OS.SessionManager.Dock.Config as Dock
import OS.SessionManager.Types exposing (..)
import OS.SessionManager.Messages exposing (..)
import Apps.Config as Apps


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , lastTick : Time
    , story : Story.Model
    , servers : Servers.Model
    , account : Account.Model
    , activeServer : ( Servers.CId, Servers.Server )
    , activeContext : Context
    , activeGateway : ( Servers.CId, Servers.Server )
    , inventory : Inventory.Model
    , backFlix : BackFlix.BackFlix
    , endpointCId : Maybe Servers.CId
    , onSetBounce : Maybe Bounces.ID -> msg
    , onNewPublicDownload : NIP -> Download.StorageId -> Filesystem.FileEntry -> msg
    , onBankAccountLogin : Finances.BankLoginRequest -> Requester -> msg
    , onBankAccountTransfer : Finances.BankTransferRequest -> Requester -> msg
    , onAccountToast : AccountNotifications.Content -> msg
    , onServerToast : ServersNotifications.Content -> msg
    , onPoliteCrash : ( String, String ) -> msg
    }


wmConfig : Servers.SessionId -> Config msg -> WindowManager.Config msg
wmConfig sessionId config =
    { toMsg = WindowManagerMsg sessionId >> config.toMsg
    , lastTick = config.lastTick
    , story = config.story
    , account = config.account
    , servers = config.servers
    , activeServer = config.activeServer
    , activeGateway = config.activeGateway
    , activeContext = config.activeContext
    , backFlix = config.backFlix
    , inventory = config.inventory
    , batchMsg = config.batchMsg
    , onNewApp = HandleNewApp >>>> config.toMsg
    , onOpenApp = HandleOpenApp >>> config.toMsg
    , onNewPublicDownload = config.onNewPublicDownload
    , onBankAccountLogin = config.onBankAccountLogin
    , onBankAccountTransfer = config.onBankAccountTransfer
    , onAccountToast = config.onAccountToast
    , onServerToast = config.onServerToast
    , onPoliteCrash = config.onPoliteCrash
    }


dockConfig : Servers.SessionId -> Config msg -> Dock.Config msg
dockConfig sessionId config =
    { toMsg = DockMsg >> config.toMsg
    , accountDock = Account.getDock config.account
    , sessionId = sessionId
    , endpointCId = Servers.getEndpointCId <| Tuple.second config.activeServer
    , wmConfig = wmConfig sessionId config
    , batchMsg = config.batchMsg
    }
