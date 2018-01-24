module OS.SessionManager.WindowManager.Config exposing (..)

import Time exposing (Time)
import Native.Panic
import Core.Error as Error
import Game.Account.Models as Account
import Game.Account.Finances.Models as Finances
import Game.Account.Notifications.Shared as AccountNotifications
import Game.BackFlix.Models as BackFlix
import Game.Inventory.Models as Inventory
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Meta.Types.Context exposing (Context(..))
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Meta.Types.Requester exposing (Requester)
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Shared as Servers exposing (CId, StorageId)
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Logs.Models as Logs
import Game.Servers.Processes.Models as Processes
import Game.Storyline.Models as Story
import Game.Storyline.Emails.Contents as Emails
import OS.SessionManager.WindowManager.Messages exposing (..)
import OS.SessionManager.WindowManager.Models as WM
import Apps.Apps as Apps
import Apps.Config as Apps


type alias Config msg =
    { toMsg : Msg -> msg
    , lastTick : Time
    , story : Story.Model
    , isCampaign : Bool
    , account : Account.Model
    , backFlix : BackFlix.BackFlix
    , servers : Servers.Model
    , activeServer : ( Servers.CId, Servers.Server )
    , activeGateway : ( Servers.CId, Servers.Server )
    , activeContext : Context
    , inventory : Inventory.Model
    , batchMsg : List msg -> msg
    , onNewApp : Maybe Context -> Maybe Apps.AppParams -> Apps.App -> msg
    , onOpenApp : Maybe Context -> Apps.AppParams -> msg
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
    , onReplyEmail : Emails.Content -> msg
    , onActionDone : Apps.App -> Context -> msg
    , onWebLogout : CId -> msg
    }


appsConfig : ( CId, Server ) -> WM.ID -> WM.TargetContext -> Config msg -> Apps.Config msg
appsConfig (( appCId, _ ) as appServer) wId targetContext config =
    { toMsg = AppMsg targetContext wId >> config.toMsg
    , lastTick = config.lastTick
    , account = config.account
    , activeServer = appServer
    , activeGateway = config.activeGateway
    , inventory = config.inventory
    , story = config.story
    , backFlix = config.backFlix
    , batchMsg = config.batchMsg
    , onNewApp = config.onNewApp
    , onOpenApp = config.onOpenApp
    , onNewPublicDownload = config.onNewPublicDownload
    , onBankAccountLogin = config.onBankAccountLogin
    , onBankAccountTransfer = config.onBankAccountTransfer
    , onAccountToast = config.onAccountToast
    , onPoliteCrash = config.onPoliteCrash
    , onNewTextFile = config.onNewTextFile appCId
    , onNewDir = config.onNewDir appCId
    , onMoveFile = config.onMoveFile appCId
    , onRenameFile = config.onRenameFile appCId
    , onDeleteFile = config.onDeleteFile appCId
    , onUpdateLog = config.onUpdateLog appCId
    , onEncryptLog = config.onEncryptLog appCId
    , onHideLog = config.onHideLog appCId
    , onDeleteLog = config.onDeleteLog appCId
    , onMotherboardUpdate = config.onMotherboardUpdate appCId
    , onPauseProcess = config.onPauseProcess appCId
    , onResumeProcess = config.onResumeProcess appCId
    , onRemoveProcess = config.onRemoveProcess appCId
    , onSetContext = config.onSetContext
    , onNewBruteforceProcess = config.onNewBruteforceProcess
    , onWebLogin = config.onWebLogin
    , onFetchUrl = config.onFetchUrl
    , onReplyEmail = config.onReplyEmail
    , onCloseApp = Close wId |> config.toMsg
    , onWebLogout = config.onWebLogout
    }


unsafeContextServer : Config msg -> Context -> ( CId, Server )
unsafeContextServer { servers, activeGateway } context =
    case (Servers.getContextServer context servers activeGateway) of
        Just sth ->
            sth

        Nothing ->
            -- TODO<Issue#421>: Implement onDeuMerda
            Error.neeiae "Missing onDeuMerda"
                |> Native.Panic.crash
