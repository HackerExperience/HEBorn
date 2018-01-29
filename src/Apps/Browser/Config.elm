module Apps.Browser.Config exposing (..)

import ContextMenu
import Html exposing (Attribute)
import Utils.Core exposing (..)
import Game.Account.Finances.Models exposing (BankLoginRequest, BankTransferRequest)
import Game.Meta.Types.Context exposing (Context(..))
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Meta.Types.Requester exposing (Requester)
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers exposing (CId)
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Processes.Requests.Download as Download
import Apps.Apps as Apps
import Apps.Browser.Messages exposing (..)
import Apps.Browser.Pages.Bank.Config as Bank
import Apps.Browser.Pages.DownloadCenter.Config as DownloadCenter
import Apps.Browser.Pages.Home.Config as Home
import Apps.Browser.Pages.Webserver.Config as Webserver


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , endpoints : List CId
    , activeServer : Servers.Server
    , activeGateway : Servers.Server
    , menuAttr : ContextMenuAttribute msg
    , onNewApp : Maybe Context -> Maybe Apps.AppParams -> Apps.App -> msg
    , onOpenApp : Maybe Context -> Apps.AppParams -> msg
    , onNewPublicDownload : NIP -> Download.StorageId -> Filesystem.FileEntry -> msg
    , onBankAccountLogin : BankLoginRequest -> Requester -> msg
    , onBankAccountTransfer : BankTransferRequest -> Requester -> msg
    , onSetContext : Context -> msg
    , onNewBruteforceProcess : Network.IP -> msg
    , onWebLogin : NIP -> Network.IP -> String -> Requester -> msg
    , onFetchUrl : Network.ID -> Network.IP -> Requester -> msg
    , onWebLogout : CId -> msg
    }


bankConfig : Config msg -> Bank.Config msg
bankConfig config =
    { toMsg = BankMsg >> ActiveTabMsg >> config.toMsg
    , onLogin = BankLogin >> config.toMsg
    , onTransfer = BankTransfer >> config.toMsg
    , onLogout = BankLogout |> config.toMsg
    }


downloadCenterConfig : Config msg -> DownloadCenter.Config msg
downloadCenterConfig config =
    { toMsg = DownloadCenterMsg >> ActiveTabMsg >> config.toMsg
    , onLogin = Login >>> ActiveTabMsg >>> config.toMsg
    , onLogout = Servers.EndpointCId >> config.onWebLogout
    , onCrack = Crack >> ActiveTabMsg >> config.toMsg
    , onAnyMap = AnyMap >> ActiveTabMsg >> config.toMsg
    , onPublicDownload = PublicDownload >>> config.toMsg
    , onSelectEndpoint = SelectEndpoint |> ActiveTabMsg |> config.toMsg
    , onNewApp = NewApp >> ActiveTabMsg >> config.toMsg
    , endpoints = config.endpoints
    }


homeConfig : Config msg -> Home.Config msg
homeConfig config =
    { onNewTabIn = NewTabIn >> config.toMsg
    , onGoAddress = GoAddress >> ActiveTabMsg >> config.toMsg
    , onOpenApp = config.onOpenApp
    }


webserverConfig : Config msg -> Webserver.Config msg
webserverConfig config =
    { toMsg = WebserverMsg >> ActiveTabMsg >> config.toMsg
    , onLogin = Login >>> ActiveTabMsg >>> config.toMsg
    , onLogout = Servers.EndpointCId >> config.onWebLogout
    , onCrack = Crack >> ActiveTabMsg >> config.toMsg
    , onAnyMap = AnyMap >> ActiveTabMsg >> config.toMsg
    , onPublicDownload = PublicDownload >>> config.toMsg
    , onSelectEndpoint = SelectEndpoint |> ActiveTabMsg |> config.toMsg
    , onNewApp = NewApp >> ActiveTabMsg >> config.toMsg
    , endpoints = config.endpoints
    }



-- helpers


type alias ContextMenuItens msg =
    List (List ( ContextMenu.Item, msg ))


type alias ContextMenuAttribute msg =
    ContextMenuItens msg -> Attribute msg
