module Apps.Browser.Config exposing (..)

import ContextMenu
import Html exposing (Attribute)
import Core.Flags as Core
import Utils.Core exposing (..)
import Game.Account.Finances.Models exposing (BankLoginRequest, BankTransferRequest)
import Apps.Params as AppParams exposing (AppParams)
import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)
import Game.Meta.Types.Context exposing (Context(..))
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Meta.Types.Apps.Desktop exposing (Reference, Requester)
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
    , onNewApp : DesktopApp -> Maybe Context -> Maybe AppParams -> CId -> msg
    , onOpenApp : AppParams -> CId -> msg
    , onSetContext : Context -> msg
    , onLogin : NIP -> Network.IP -> String -> Requester -> msg
    , onLogout : CId -> msg
    , onNewPublicDownload : NIP -> Download.StorageId -> Filesystem.FileEntry -> msg
    , onNewBruteforceProcess : Network.IP -> msg
    , onBankAccountLogin : BankLoginRequest -> Requester -> msg
    , onBankAccountTransfer : BankTransferRequest -> Requester -> msg
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
    , onLogin = Login >>> ActiveTabMsg >>> config.toMsg
    , onLogout = Servers.EndpointCId >> config.onLogout
    , onCrack = Crack >> ActiveTabMsg >> config.toMsg
    , onAnyMap = AnyMap >> ActiveTabMsg >> config.toMsg
    , onPublicDownload = PublicDownload >>> config.toMsg
    , onSelectEndpoint = SelectEndpoint |> ActiveTabMsg |> config.toMsg
    , onNewApp = NewApp >> ActiveTabMsg >> config.toMsg
    , endpoints = endpoints config
    }


homeConfig : Config msg -> Home.Config msg
homeConfig config =
    { onNewTabIn = NewTabIn >> config.toMsg
    , onGoAddress = GoAddress >> ActiveTabMsg >> config.toMsg
    , onOpenApp =
        config
            |> endpointCId
            |> Maybe.map (flip config.onOpenApp)
            |> Maybe.withDefault (always <| config.batchMsg [])
    }


webserverConfig : Config msg -> Webserver.Config msg
webserverConfig config =
    { toMsg = WebserverMsg >> ActiveTabMsg >> config.toMsg
    , onLogin = Login >>> ActiveTabMsg >>> config.toMsg
    , onLogout = Servers.EndpointCId >> config.onLogout
    , onCrack = Crack >> ActiveTabMsg >> config.toMsg
    , onAnyMap = AnyMap >> ActiveTabMsg >> config.toMsg
    , onPublicDownload = PublicDownload >>> config.toMsg
    , onSelectEndpoint = SelectEndpoint |> ActiveTabMsg |> config.toMsg
    , onNewApp = NewApp >> ActiveTabMsg >> config.toMsg
    , endpoints = endpoints config
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
