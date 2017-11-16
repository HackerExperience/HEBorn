module Core.Subscribers.Websocket exposing (dispatch)

import Json.Decode exposing (Value)
import Core.Dispatch.Websocket exposing (..)
import Driver.Websocket.Channels as Channels exposing (Channel)
import Core.Subscribers.Helpers exposing (..)
import Core.Messages as Core
import Driver.Websocket.Messages as Ws
import Setup.Messages as Setup
import Game.Messages as Game
import Game.Account.Messages as Account
import Game.Servers.Messages as Servers
import Game.Servers.Shared exposing (CId)
import Game.Servers.Processes.Messages as Processes
import Game.Web.Messages as Web


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        Connected a ->
            [ Core.HandleConnected
            , account Account.HandleConnected
            , game Game.HandleConnected
            ]

        Disconnected ->
            [ account Account.HandleDisconnected ]

        Join a b ->
            [ ws <| Ws.HandleJoin a b ]

        Joined a b ->
            fromJoined a b

        JoinFailed a b ->
            fromJoinFailed a b

        Leave a ->
            [ ws <| Ws.HandleLeave a ]

        Leaved a b ->
            []



-- internals


fromJoined : Channel -> Value -> Subscribers
fromJoined channel value =
    case channel of
        Channels.AccountChannel _ ->
            [ game <| Game.HandleJoinedAccount value
            , setup <| Setup.HandleJoinedAccount value
            ]

        Channels.ServerChannel cid ->
            [ servers <| Servers.HandleJoinedServer cid value
            , setup <| Setup.HandleJoinedServer cid
            ]

        _ ->
            []


fromJoinFailed : Channel -> Value -> Subscribers
fromJoinFailed channel value =
    case channel of
        Channels.ServerChannel cid ->
            [ web <| Web.HandleJoinServerFailed cid
            ]

        _ ->
            []
