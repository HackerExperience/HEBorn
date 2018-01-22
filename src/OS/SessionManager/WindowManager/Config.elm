module OS.SessionManager.WindowManager.Config exposing (..)

import Time exposing (Time)
import Game.Account.Models as Account
import Game.Account.Finances.Models as Finances
import Game.BackFlix.Models as BackFlix
import Game.Inventory.Models as Inventory
import Game.Meta.Types.Context exposing (Context(..))
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Meta.Types.Requester exposing (Requester)
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Processes.Requests.Download as Download
import Game.Storyline.Models as Story
import OS.SessionManager.Types exposing (..)
import OS.SessionManager.WindowManager.Messages exposing (..)
import OS.SessionManager.WindowManager.Models as WM
import Apps.Apps as Apps
import Apps.Config as Apps


type alias Config msg =
    { toMsg : Msg -> msg
    , lastTick : Time
    , story : Story.Model
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
    , onNewPublicDownload : NIP -> Download.StorageId -> Filesystem.FileEntry -> msg
    , onBankAccountLogin : Finances.BankLoginRequest -> Requester -> msg
    , onBankAccountTransfer : Finances.BankTransferRequest -> Requester -> msg
    }


appsConfig : Maybe Context -> WM.ID -> WM.TargetContext -> Config msg -> Apps.Config msg
appsConfig maybeContext wId targetContext config =
    { toMsg = AppMsg targetContext wId >> config.toMsg
    , lastTick = config.lastTick
    , account = config.account
    , activeServer =
        Servers.getContextServer
            maybeContext
            config.servers
            (Tuple.second config.activeGateway)
    , inventory = config.inventory
    , story = config.story
    , backFlix = config.backFlix
    , batchMsg = config.batchMsg
    , onNewApp = config.onNewApp
    , onOpenApp = config.onOpenApp
    , onNewPublicDownload = config.onNewPublicDownload
    , onBankAccountLogin = config.onBankAccountLogin
    , onBankAccountTransfer = config.onBankAccountTransfer
    }
