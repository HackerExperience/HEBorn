module OS.Config exposing (..)

import Time exposing (Time)
import Core.Flags exposing (Flags)
import Game.Account.Bounces.Shared as Bounces
import Game.Account.Models as Account
import Game.Meta.Types.Context exposing (..)
import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Shared exposing (CId)
import Game.Servers.Models as Servers exposing (Server)
import Game.BackFlix.Models as BackFlix
import Game.Inventory.Models as Inventory
import Game.Servers.Models as Servers
import Game.Storyline.Models as Story
import OS.SessionManager.Config as SessionManager
import OS.Messages exposing (..)
import OS.Header.Config as Header
import OS.Console.Config as Console
import OS.Toasts.Config as Toasts


type alias Config msg =
    { toMsg : Msg -> msg
    , flags : Flags
    , account : Account.Model
    , servers : Servers.Model
    , story : Story.Model
    , activeServer : ( CId, Server )
    , activeContext : Context
    , activeGateway : ( CId, Server )
    , lastTick : Time
    , onLogout : msg
    , onSetGateway : CId -> msg
    , onSetEndpoint : Maybe CId -> msg
    , onSetContext : Context -> msg
    , onSetBounce : Maybe Bounces.ID -> msg
    , onSetStoryMode : Bool -> msg
    , onReadAllAccountNotifications : msg
    , onReadAllServerNotifications : msg
    , onSetActiveNIP : NIP -> msg
    , inventory : Inventory.Model
    , backFlix : BackFlix.BackFlix
    }


smConfig : Config msg -> SessionManager.Config msg
smConfig config =
    { toMsg = SessionManagerMsg >> config.toMsg
    , lastTick = config.lastTick
    , story = config.story
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
    , onSetBounce = config.onSetBounce
    }


headerConfig : Config msg -> Header.Config msg
headerConfig config =
    { toMsg = HeaderMsg >> config.toMsg
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
    , onSetStoryMode =
        config.onSetStoryMode
    , onReadAllAccountNotifications =
        config.onReadAllAccountNotifications
    , onReadAllServerNotifications =
        config.onReadAllServerNotifications
    , onSetActiveNIP =
        config.onSetActiveNIP
    , bounces =
        Account.getBounces config.account
    , gateways =
        Account.getGateways config.account
    , endpoints =
        config.activeServer
            |> Tuple.second
            |> Servers.getEndpoints
    , servers =
        config.servers
    , nips =
        config.activeServer
            |> Tuple.second
            |> Servers.getNIPs
    , activeEndpointCid =
        config.activeServer
            |> Tuple.second
            |> Servers.getEndpointCId
    , activeGateway =
        config.activeGateway
    , activeBounce =
        config.activeServer
            |> Tuple.second
            |> Servers.getBounce
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
    }


consoleConfig : Config msg -> Console.Config
consoleConfig config =
    { backFlix = config.backFlix }


toastConfig : Config msg -> Toasts.Config msg
toastConfig config =
    { toMsg = ToastsMsg >> config.toMsg }
