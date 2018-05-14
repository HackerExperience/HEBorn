module Apps.Browser.Config exposing (..)

import ContextMenu
import Html exposing (Attribute)
import Core.Flags as Core
import Utils.Core exposing (..)
import Apps.Params as AppParams exposing (AppParams)
import Game.Account.Database.Models exposing (HackedServers)
import Game.Account.Finances.Requests.Login as LoginRequest
import Game.Account.Finances.Requests.Transfer as TransferRequest
import Game.Meta.Types.Desktop.Apps as DesktopApp exposing (DesktopApp)
import Game.Meta.Types.Context exposing (Context(..))
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Meta.Types.Desktop.Apps exposing (Reference, Requester)
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers exposing (CId)
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Processes.Requests.Download as Download
import Apps.Browser.Messages exposing (..)
import Apps.Browser.Pages.Bank.Config as Bank
import Apps.Browser.Pages.DownloadCenter.Config as DownloadCenter
import Apps.Browser.Pages.Home.Config as Home
import Apps.Browser.Pages.Webserver.Config as Webserver


{-| Callbacks:

  - `onBruteforceProcess` targets gateway cid
  - `onNewPublicDownload` targets active cid

-}
type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , reference : Reference
    , activeServer : ( CId, Servers.Server )
    , activeGateway : ( CId, Servers.Server )
    , hackedServers : HackedServers
    , onNewApp : DesktopApp -> Maybe Context -> Maybe AppParams -> CId -> msg
    , onOpenApp : AppParams -> CId -> msg
    , onSetContext : Context -> msg
    , onLogin : NIP -> Network.IP -> String -> Requester -> msg
    , onLogout : CId -> msg
    , onSetEndpoint : Maybe CId -> msg
    , onNewPublicDownload : NIP -> Download.StorageId -> Filesystem.FileEntry -> msg
    , onNewBruteforceProcess : Network.IP -> msg
    , onBankAccountLogin : LoginRequest.Payload -> Requester -> msg
    , onBankAccountTransfer : TransferRequest.Payload -> Requester -> msg
    , menuAttr : ContextMenuAttribute msg
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
    , batchMsg = config.batchMsg
    , hackedServers = config.hackedServers
    , endpoints = endpoints config
    , onLogin = Login >>> ActiveTabMsg >>> config.toMsg
    , onLogout = Servers.EndpointCId >> config.onLogout
    , onCrack = Crack >> ActiveTabMsg >> config.toMsg
    , onAnyMap = AnyMap >> ActiveTabMsg >> config.toMsg
    , onPublicDownload = PublicDownload >>> config.toMsg
    , onSelectEndpoint = SelectEndpoint |> ActiveTabMsg |> config.toMsg
    , onSetEndpoint = config.onSetEndpoint
    , onNewApp = NewApp >> ActiveTabMsg >> config.toMsg
    }


homeConfig : Config msg -> Home.Config msg
homeConfig config =
    let
        ( cid, server ) =
            config.activeGateway
    in
        { onNewTabIn = NewTabIn >> config.toMsg
        , onGoAddress = GoAddress >> ActiveTabMsg >> config.toMsg
        , onOpenApp =
            -- Home only exists in Global Network (::)
            flip config.onOpenApp cid
        }


webserverConfig : Config msg -> Webserver.Config msg
webserverConfig config =
    { toMsg = WebserverMsg >> ActiveTabMsg >> config.toMsg
    , batchMsg = config.batchMsg
    , endpoints = endpoints config
    , hackedServers = config.hackedServers
    , onLogin = Login >>> ActiveTabMsg >>> config.toMsg
    , onLogout = Servers.EndpointCId >> config.onLogout
    , onCrack = Crack >> ActiveTabMsg >> config.toMsg
    , onAnyMap = AnyMap >> ActiveTabMsg >> config.toMsg
    , onPublicDownload = PublicDownload >>> config.toMsg
    , onSelectEndpoint = SelectEndpoint |> ActiveTabMsg |> config.toMsg
    , onSetEndpoint = config.onSetEndpoint
    , onNewApp = NewApp >> ActiveTabMsg >> config.toMsg
    }



-- helpers


endpointCId : Config msg -> Maybe CId
endpointCId { activeGateway } =
    activeGateway
        |> Tuple.second
        |> Servers.getEndpointCId


endpoints : Config msg -> List CId
endpoints { activeGateway } =
    activeGateway
        |> Tuple.second
        |> Servers.getEndpoints
        |> Maybe.withDefault []


type alias ContextMenuItens msg =
    List (List ( ContextMenu.Item, msg ))


type alias ContextMenuAttribute msg =
    ContextMenuItens msg -> Attribute msg
