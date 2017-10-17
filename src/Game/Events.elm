module Game.Events exposing (dispatcher)

import Game.Models exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Events.Events as Events exposing (Event)
import Events.Account as Account
import Events.Server as Server
import Driver.Websocket.Reports as Ws
import Driver.Websocket.Channels exposing (..)
import Game.Messages exposing (..)


-- game

import Game.Account.Messages as Account
import Game.Account.Database.Messages as Database
import Game.Storyline.Emails.Messages as Emails
import Game.Storyline.Missions.Messages as Missions
import Game.Servers.Messages as Servers
import Game.Servers.Shared as Servers
import Game.Servers.Processes.Messages as Processes
import Game.Web.Messages as Web


-- apps

import Apps.Messages as Apps
import Apps.Browser.Messages as Browser


type alias Dispatches =
    List Dispatch


dispatcher : Event -> Model -> Dispatch
dispatcher event model =
    let
        dispatches =
            case event of
                Events.Report report ->
                    fromReport report model

                Events.Account event ->
                    fromAccount event model

                Events.Server cid event ->
                    fromServer cid event model
    in
        Dispatch.batch dispatches



-- reports


fromReport : Ws.Report -> Model -> Dispatches
fromReport =
    let
        handleWsConnected token =
            [ Dispatch.account Account.HandleConnect
            , Dispatch.game HandleConnected
            ]

        handleWsDisconnected =
            [ Dispatch.account Account.HandleDisconnect
            ]

        handleWsJoined channel value =
            case channel of
                ServerChannel cid ->
                    [ Dispatch.servers <| Servers.HandleJoinedServer cid value
                    , Dispatch.web <| Web.HandleJoinedServer cid
                    ]

                AccountChannel id ->
                    [ Dispatch.game <| HandleJoinedAccount value
                    ]

                RequestsChannel ->
                    []

        handleWsJoinFailed channel value =
            case channel of
                ServerChannel cid ->
                    [ Dispatch.web <| Web.HandleJoinServerFailed cid
                    ]

                AccountChannel id ->
                    []

                RequestsChannel ->
                    []

        handler report model =
            case report of
                Ws.Connected token ->
                    handleWsConnected token

                Ws.Disconnected ->
                    handleWsDisconnected

                Ws.Joined channel value ->
                    handleWsJoined channel value

                Ws.JoinFailed channel value ->
                    handleWsJoinFailed channel value
    in
        handler



-- account channel events


fromAccount : Account.Event -> Model -> Dispatches
fromAccount =
    let
        handlePasswordAcquired data =
            -- TODO: discuss format change with renato to allow easy
            -- dispatch to processes, do not let this note pass on
            -- review
            [ Dispatch.database <| Database.HandlePasswordAcquired data
            , Dispatch.apps
                [ Apps.BrowserMsg <| Browser.HandlePasswordAcquired data
                ]
            ]

        handleStoryNewEmail data =
            [ Dispatch.email <| Emails.HandleNewEmail data
            ]

        handleStoryStepProceeded data =
            [ Dispatch.mission <| Missions.HandleStepProceeded data
            ]

        handler event model =
            case event of
                Account.PasswordAcquired data ->
                    handlePasswordAcquired data

                Account.StoryNewEmail data ->
                    handleStoryNewEmail data

                Account.StoryStepProceeded data ->
                    handleStoryStepProceeded data
    in
        handler



-- server channel events


fromServer : Servers.CId -> Server.Event -> Model -> Dispatches
fromServer =
    let
        handleLogsChanged cid data =
            []

        handleNewFile cid data =
            []

        handleProcessStarted cid data =
            [ Dispatch.processes cid <| Processes.HandleProcessStarted data
            ]

        handleProcessConclusion cid data =
            [ Dispatch.processes cid <| Processes.HandleProcessConclusion data
            ]

        handleBruteforceFailed cid data =
            [ Dispatch.processes cid <| Processes.HandleBruteforceFailed data
            ]

        handleProcessesChanged cid data =
            [ Dispatch.processes cid <| Processes.HandleProcessesChanged data
            ]

        handler cid event model =
            case event of
                Server.LogsChanged data ->
                    handleLogsChanged cid data

                Server.NewFile data ->
                    handleNewFile cid data

                Server.ProcessStarted data ->
                    handleProcessStarted cid data

                Server.ProcessConclusion data ->
                    handleProcessConclusion cid data

                Server.BruteforceFailed data ->
                    handleBruteforceFailed cid data

                Server.ProcessesChanged data ->
                    handleProcessesChanged cid data
    in
        handler
