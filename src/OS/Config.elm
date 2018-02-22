module OS.Config exposing (..)

import ContextMenu
import Html exposing (Html, Attribute)
import Time exposing (Time)
import Core.Flags exposing (Flags)
import Game.Account.Models as Account
import Game.Account.Bounces.Shared as Bounces
import Game.Account.Finances.Models as Finances
import Game.Account.Notifications.Shared as AccountNotifications
import Game.BackFlix.Models as BackFlix
import Game.Inventory.Models as Inventory
import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Meta.Types.Context exposing (..)
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Meta.Types.Apps.Desktop exposing (Requester)
import Game.Servers.Shared exposing (CId, StorageId)
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Logs.Models as Logs
import Game.Servers.Processes.Models as Processes
import Game.Servers.Notifications.Shared as ServersNotifications
import Game.Storyline.Models as Story
import Game.Storyline.Shared as Story
import OS.Messages exposing (..)
import OS.Console.Config as Console
import OS.Header.Config as Header
import OS.WindowManager.Config as WindowManager
import OS.Toasts.Config as Toasts


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , flags : Flags
    , account : Account.Model
    , backFlix : BackFlix.BackFlix
    , inventory : Inventory.Model
    , servers : Servers.Model
    , story : Story.Model
    , activeServer : ( CId, Server )
    , activeContext : Context
    , activeGateway : ( CId, Server )
    , isCampaign : Bool
    , lastTick : Time
    , menuView : Html msg
    , menuAttr : ContextMenuAttribute msg
    , onLogout : msg
    , onSetGateway : CId -> msg
    , onSetEndpoint : Maybe CId -> msg
    , onSetContext : Context -> msg
    , onSetBounce : Maybe Bounces.ID -> msg
    , onReadAllAccountNotifications : msg
    , onReadAllServerNotifications : msg
    , onSetActiveNIP : NIP -> msg
    , onNewPublicDownload : NIP -> StorageId -> Filesystem.FileEntry -> msg
    , onBankAccountLogin : Finances.BankLoginRequest -> Requester -> msg
    , onBankAccountTransfer : Finances.BankTransferRequest -> Requester -> msg
    , onAccountToast : AccountNotifications.Content -> msg
    , onServerToast : CId -> ServersNotifications.Content -> msg
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
    , onNewBruteforceProcess : CId -> Network.IP -> msg
    , onWebLogin : CId -> NIP -> Network.IP -> String -> Requester -> msg
    , onFetchUrl : CId -> Network.ID -> Network.IP -> Requester -> msg
    , onReplyEmail : String -> Story.Reply -> msg
    , onActionDone : DesktopApp -> Context -> msg
    , onWebLogout : CId -> msg
    , onDropHeaderMenu : msg
    , accountId : String
    }


windowManagerConfig : Config msg -> WindowManager.Config msg
windowManagerConfig config =
    { toMsg = WindowManagerMsg >> config.toMsg
    , batchMsg = config.batchMsg
    , flags = config.flags
    , lastTick = config.lastTick
    , story = config.story
    , isCampaign = config.isCampaign
    , servers = config.servers
    , account = config.account
    , activeServer = config.activeServer
    , activeContext = config.activeContext
    , activeGateway = config.activeGateway
    , inventory = config.inventory
    , backFlix = config.backFlix
    , endpointCId =
        config.activeServer
            |> Tuple.second
            |> Servers.getEndpointCId
    , accountId = config.accountId
    , menuAttr = config.menuAttr
    , onSetBounce = config.onSetBounce
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
    , onNewBruteforceProcess = config.onNewBruteforceProcess
    , onWebLogin = config.onWebLogin
    , onFetchUrl = config.onFetchUrl
    , onReplyEmail = config.onReplyEmail
    , onActionDone = config.onActionDone
    , onWebLogout = config.onWebLogout
    }


headerConfig : Config msg -> Header.Config msg
headerConfig config =
    { toMsg = HeaderMsg >> config.toMsg
    , batchMsg = config.batchMsg
    , bounces =
        Account.getBounces config.account
    , gateways =
        Account.getGateways config.account
    , endpoints =
        config.activeGateway
            |> Tuple.second
            |> Servers.getEndpoints
            |> Maybe.withDefault []
    , servers =
        config.servers
    , nips =
        config.activeServer
            |> Tuple.second
            |> Servers.getNIPs
    , activeEndpointCid =
        config.activeGateway
            |> Tuple.second
            |> Servers.getEndpointCId
    , activeGateway =
        config.activeGateway
    , activeBounce =
        config.activeServer
            |> Tuple.second
            |> flip Servers.getActiveBounce config.servers
    , activeContext =
        config.activeContext
    , serversNotifications =
        config.activeServer
            |> Tuple.second
            |> Servers.getNotifications
    , activeNIP =
        config.activeServer
            |> Tuple.second
            |> Servers.getActiveNIP
    , menuAttr = config.menuAttr
    , onLogout =
        config.onLogout
    , onSetGateway =
        config.onSetGateway
    , onSetEndpoint =
        config.onSetEndpoint
    , onSetContext =
        config.onSetContext
    , onSetBounce =
        config.onSetBounce
    , onReadAllAccountNotifications =
        config.onReadAllAccountNotifications
    , onReadAllServerNotifications =
        config.onReadAllServerNotifications
    , onSetActiveNIP =
        config.onSetActiveNIP
    }


consoleConfig : Config msg -> Console.Config
consoleConfig config =
    { backFlix = config.backFlix }


toastsConfig : Config msg -> Toasts.Config msg
toastsConfig config =
    { toMsg = ToastsMsg >> config.toMsg }



-- helpers


type alias ContextMenuItens msg =
    List (List ( ContextMenu.Item, msg ))


type alias ContextMenuAttribute msg =
    ContextMenuItens msg -> Attribute msg
