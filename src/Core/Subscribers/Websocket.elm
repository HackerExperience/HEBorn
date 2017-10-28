module Core.Subscribers.Websocket exposing (dispatch)

import Json.Decode exposing (Value)
import Core.Dispatch.Websocket exposing (..)
import Driver.Websocket.Channels as Channels exposing (Channel)
import Core.Subscribers.Helpers exposing (..)
import Core.Messages as Core
import Driver.Websocket.Messages as Ws
import Setup.Messages as Setup
import Apps.Messages as Apps
import Apps.Browser.Messages as Browser
import Game.Messages as Game
import Game.Account.Messages as Account
import Game.Account.Database.Messages as Database
import Game.Storyline.Emails.Messages as Emails
import Game.Storyline.Missions.Messages as Missions
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

        Event a b ->
            fromEvent a b



-- internals


fromJoined : Channel -> Value -> Subscribers
fromJoined channel value =
    case channel of
        Channels.AccountChannel _ ->
            [ game <| Game.HandleJoinedAccount value
            , setup <| Setup.HandleJoinedAccount value
            ]

        Channels.ServerChannel cid ->
            [ servers <| Servers.HandleJoinedServer cid value ]

        _ ->
            []


fromJoinFailed : Channel -> Value -> Subscribers
fromJoinFailed channel value =
    case channel of
        Channels.ServerChannel cid ->
            [ web <| Web.HandleJoinServerFailed cid ]

        _ ->
            []


fromEvent : Channel -> Event -> Subscribers
fromEvent channel event =
    case event of
        AccountEvent event ->
            fromAccount event

        ServerEvent event ->
            case channel of
                Channels.ServerChannel cid ->
                    fromServer cid event

                _ ->
                    -- TODO: crash
                    []


fromAccount : AccountEvent -> Subscribers
fromAccount event =
    case event of
        PasswordAcquired data ->
            [ database <| Database.HandlePasswordAcquired data
            , apps [ Apps.BrowserMsg <| Browser.HandlePasswordAcquired data ]
            ]

        StoryNewEmail data ->
            [ emails <| Emails.HandleNewEmail data
            ]

        StoryStepProceeded data ->
            [ missions <| Missions.HandleStepProceeded data
            ]

        StoryReplyUnlocked data ->
            [ emails <| Emails.HandleReplyUnlocked data
            ]


fromServer : CId -> ServerEvent -> Subscribers
fromServer cid event =
    case event of
        ProcessStarted data ->
            [ processes cid <| Processes.HandleProcessStarted data
            ]

        ProcessConclusion data ->
            [ processes cid <| Processes.HandleProcessConclusion data
            ]

        BruteforceFailed data ->
            [ processes cid <| Processes.HandleBruteforceFailed data
            ]

        ProcessesChanged data ->
            [ processes cid <| Processes.HandleProcessesChanged data
            ]

        _ ->
            []
