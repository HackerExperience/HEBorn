module OS.Config exposing (..)

import ContextMenu
import Html exposing (Html, Attribute)
import Utils.Core exposing (..)
import Core.Flags exposing (Flags)
import Game.Models as Game
import Game.Messages as Game
import Game.Account.Messages as Account
import Game.Account.Models as Account
import Game.Account.Bounces.Shared as Bounces
import Game.Account.Notifications.Messages as AccountNotifications
import Game.Account.Notifications.Shared as AccountNotifications
import Game.Meta.Types.Desktop.Apps as DesktopApp exposing (DesktopApp)
import Game.Meta.Types.Context exposing (..)
import Game.Meta.Types.Desktop.Apps exposing (Requester)
import Game.Servers.Shared exposing (CId, StorageId)
import Game.Servers.Messages as Servers
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Notifications.Messages as ServersNotifications
import OS.Console.Config as Console
import OS.Header.Config as Header
import OS.WindowManager.Config as WindowManager
import OS.WindowManager.Messages as WindowManager
import OS.Toasts.Config as Toasts
import OS.Toasts.Messages as Toasts
import OS.Messages exposing (..)


type alias Config msg =
    { flags : Flags
    , toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , awaitEvent : String -> ( String, msg ) -> msg
    , gameMsg : Game.Msg -> msg
    , game : Game.Model
    , activeContext : Context
    , activeServer : ( CId, Server )
    , activeGateway : ( CId, Server )
    , onActionDone : DesktopApp -> Context -> msg
    , menuAttr : ContextMenuAttribute msg
    , menuView : Html msg
    }


windowManagerConfig : Config msg -> WindowManager.Config msg
windowManagerConfig config =
    { flags = config.flags
    , toMsg = WindowManagerMsg >> config.toMsg
    , batchMsg = config.batchMsg
    , awaitEvent = config.awaitEvent
    , gameMsg = config.gameMsg
    , game = config.game
    , activeContext = config.activeContext
    , activeServer = config.activeServer
    , activeGateway = config.activeGateway
    , onSetContext = onSetContext config
    , onActionDone = config.onActionDone
    , onAccountToast = onAccountToast config
    , menuAttr = config.menuAttr
    }


headerConfig : Config msg -> Header.Config msg
headerConfig ({ game } as config) =
    let
        servers_ =
            Game.getServers game

        server_ =
            Tuple.second config.activeServer

        account_ =
            Game.getAccount game

        ( cid, gateway ) =
            config.activeGateway

        endpoints =
            gateway
                |> Servers.getEndpoints
                |> Maybe.withDefault []

        onReadAllAccountNotifications =
            accountNotif config AccountNotifications.HandleReadAll

        onReadAllServerNotifications =
            serverNotif config cid ServersNotifications.HandleReadAll
    in
        { toMsg = HeaderMsg >> config.toMsg
        , batchMsg = config.batchMsg
        , activeContext = config.activeContext
        , activeGatewayCId = cid
        , activeEndpointCId = Servers.getEndpointCId gateway
        , activeBounce = Servers.getBounce server_
        , activeNIP = Servers.getActiveNIP server_
        , gateways = Account.getGateways account_
        , endpoints = endpoints
        , bounces = Account.getBounces account_
        , nips = Servers.getNIPs server_
        , accountNotifications = Account.getNotifications account_
        , serversNotifications = Servers.getNotifications server_
        , onOpenApp = WindowManager.OpenApp >>> WindowManagerMsg >>> config.toMsg
        , onSignOut = onSignOut config
        , onSetGateway = Account.HandleSetGateway >> account config
        , onSetEndpoint = Account.HandleSetEndpoint >> account config
        , onSetContext = onSetContext config
        , onSetBounce = onSetBounce config
        , onReadAllAccountNotifications = onReadAllAccountNotifications
        , onReadAllServerNotifications = onReadAllServerNotifications
        , onSetActiveNIP = Servers.HandleSetActiveNIP >> server config cid
        , getLabel = flip Servers.getLabel servers_
        , menuAttr = config.menuAttr
        }


consoleConfig : Config msg -> Console.Config
consoleConfig config =
    { logs = Game.getBackFlix config.game }


toastsConfig : Config msg -> Toasts.Config msg
toastsConfig config =
    { toMsg = ToastsMsg >> config.toMsg }



-- dispatch helpers


account : Config msg -> Account.Msg -> msg
account config =
    Game.AccountMsg >> config.gameMsg


accountNotif : Config msg -> AccountNotifications.Msg -> msg
accountNotif config =
    Account.NotificationsMsg >> account config


servers : Config msg -> Servers.Msg -> msg
servers config =
    Game.ServersMsg >> config.gameMsg


server : Config msg -> CId -> Servers.ServerMsg -> msg
server config cid =
    Servers.ServerMsg cid >> servers config


serverNotif : Config msg -> CId -> ServersNotifications.Msg -> msg
serverNotif config cid =
    Servers.NotificationsMsg >> server config cid



-- helpers


onSetContext : Config msg -> Context -> msg
onSetContext config =
    Account.HandleSetContext >> account config


onAccountToast : Config msg -> AccountNotifications.Content -> msg
onAccountToast config =
    Toasts.HandleAccount >> ToastsMsg >> config.toMsg


onSignOut : Config msg -> msg
onSignOut config =
    account config <| Account.HandleSignOut


onSetBounce : Config msg -> Maybe Bounces.ID -> msg
onSetBounce ({ activeGateway } as config) =
    let
        cid =
            activeGateway
                |> Tuple.second
                |> Servers.getEndpointCId
                |> Maybe.withDefault (Tuple.first activeGateway)
    in
        Servers.HandleSetBounce >> server config cid


isCampaignFromConfig : Config msg -> Bool
isCampaignFromConfig { activeServer } =
    activeServer
        |> Tuple.second
        |> Servers.getType
        |> (==) Servers.DesktopCampaign


type alias ContextMenuItens msg =
    List (List ( ContextMenu.Item, msg ))


type alias ContextMenuAttribute msg =
    ContextMenuItens msg -> Attribute msg
