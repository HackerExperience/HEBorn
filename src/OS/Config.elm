module OS.Config exposing (..)

import Time exposing (Time)
import Game.Account.Bounces.Shared as Bounces
import Game.Account.Models as Account
import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Shared exposing (CId)
import Game.Servers.Models as Servers exposing (Server, Servers)
import Game.Storyline.Models as Story
import OS.SessionManager.Config as SessionManager
import OS.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , flags : Flags
    , account : Account.Model
    , story : Story.Model
    , activeCId : CId
    , activeServer : (CId, Server)
    , activeContext : Context
    , activeGateway : (CId, Server)
    , servers : Servers
    , lastTick : Time
    , onLogout : msg
    , onSetGateway : msg
    , onSetEndpoint : msg
    , onSetContext : msg
    , onSetBounce : Bounces.ID -> msg
    , onSetStoryMode : msg
    , onReadAllAccountNotifications : msg
    , onReadAllServerNotifications : msg
    , onSetActiveNIP : NIP -> msg
    }


smConfig : Config msg -> SessionManager.Config msg
smConfig { account, story, activeServer, lastTick, toMsg } =
    { toMsg = SessionManagerMsg >> toMsg
    , lastTick = lastTick
    , account = account
    , story = story
    , activeServer = activeServer
    , activeContext = Account.getContext account


headerConfig : Config msg -> Header.Config msg
headerConfig config =
    { toMsg = HeaderMsg
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
    , nips =
        config.activeServer
            |> Tuple.second
            |> Server.getNips
    , activeEndpointCid =
        Servers.getEndpointCId config.activeServer
    , activeBounce =
        Server.getBounce config.activeServer
    }
