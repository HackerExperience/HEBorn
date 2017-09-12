module Game.Servers.Processes.IntegrationTest exposing (all)

import Expect
import Fuzz exposing (tuple, tuple3)
import Test exposing (Test, describe)
import Json.Decode as Decode
import TestUtils exposing (fuzz, updateGame, fromJust, fromOk, toValue)
import Requests.Types exposing (Code(OkCode))
import Gen.Processes as GenProcesses
import Gen.Game as GenGame
import Driver.Websocket.Channels exposing (Channel(..))
import Events.Events as Events exposing (Event(ServersEvent))
import Events.Servers exposing (Event(ServerEvent), ServerEvent(ProcessesEvent))
import Events.Servers.Processes as ProcessesEvent
import Game.Messages as Game
import Game.Models as Game
import Game.Servers.Messages as Servers
import Game.Servers.Models as Servers
import Game.Servers.Processes.Models exposing (..)
import Game.Servers.Processes.Models exposing (..)
import Game.Servers.Processes.Messages exposing (..)
import Game.Servers.Processes.Models exposing (..)
import Game.Servers.Processes.Update exposing (..)


all : Test
all =
    describe "process integration tests"
        [ describe "reacting to events"
            eventTests
        , describe "reacting to requests"
            requestTests
        ]



--------------------------------------------------------------------------------
-- Event Tests
--------------------------------------------------------------------------------


eventTests : List Test
eventTests =
    [ fuzz
        (tuple ( GenGame.model, GenProcesses.id ))
        "event 'process.started' creates a process"
      <|
        \( game, id ) ->
            let
                ( serverId, server ) =
                    fromJust <| Game.getGateway game

                -- building event
                channel =
                    ServerChannel

                context =
                    Just serverId

                name =
                    "processes.started"

                json =
                    toValue
                        ("{\"process_id\":\""
                            ++ id
                            ++ "\",\"type\":\"Cracker\"}"
                        )

                msg =
                    Events.handler channel context name json
                        |> fromJust
                        |> Game.Event
            in
                game
                    |> updateGame msg
                    |> Game.getServers
                    |> Servers.get serverId
                    |> fromJust
                    |> Servers.getProcesses
                    |> get id
                    |> Maybe.map (always "exists")
                    |> Expect.equal (Just "exists")
    , fuzz
        (tuple3 ( GenGame.model, GenProcesses.id, GenProcesses.fullProcess ))
        "event 'process.conclusion' concludes a process"
      <|
        \( game0, id, process0 ) ->
            let
                ( serverId, server0 ) =
                    fromJust <| Game.getGateway game0

                process1 =
                    { process0 | state = Running }

                processes0 =
                    Servers.getProcesses server0

                processes1 =
                    insert id process1 processes0

                server1 =
                    Servers.setProcesses processes1 server0

                servers1 =
                    Servers.insert serverId server1 (Game.getServers game0)

                game1 =
                    Game.setServers servers1 game0

                -- building event
                channel =
                    ServerChannel

                context =
                    Just serverId

                name =
                    "processes.conclusion"

                json =
                    toValue
                        ("{\"process_id\":\""
                            ++ id
                            ++ "\"}"
                        )

                msg =
                    Events.handler channel context name json
                        |> fromJust
                        |> Game.Event
            in
                game1
                    |> updateGame msg
                    |> Game.getServers
                    |> Servers.get serverId
                    |> fromJust
                    |> Servers.getProcesses
                    |> get id
                    |> fromJust
                    |> getState
                    |> Expect.equal (Completed Nothing)
    , fuzz
        (tuple3 ( GenGame.model, GenProcesses.id, GenProcesses.fullProcess ))
        "event 'process.bruteforce_failed' concludes a process"
      <|
        \( game0, id, process0 ) ->
            let
                ( serverId, server0 ) =
                    fromJust <| Game.getGateway game0

                process1 =
                    { process0 | state = Running }

                processes0 =
                    Servers.getProcesses server0

                processes1 =
                    insert id process1 processes0

                server1 =
                    Servers.setProcesses processes1 server0

                servers1 =
                    Servers.insert serverId server1 (Game.getServers game0)

                game1 =
                    Game.setServers servers1 game0

                -- building event
                channel =
                    ServerChannel

                context =
                    Just serverId

                name =
                    "processes.bruteforce_failed"

                json =
                    toValue
                        ("{\"process_id\":\""
                            ++ id
                            ++ "\", \"reason\": \"any\"}"
                        )

                msg =
                    Events.handler channel context name json
                        |> fromJust
                        |> Game.Event
            in
                game1
                    |> updateGame msg
                    |> Game.getServers
                    |> Servers.get serverId
                    |> fromJust
                    |> Servers.getProcesses
                    |> get id
                    |> fromJust
                    |> getState
                    |> Expect.equal (Completed Nothing)
    ]



--------------------------------------------------------------------------------
-- Request Tests
--------------------------------------------------------------------------------


requestTests : List Test
requestTests =
    [ fuzz
        GenGame.model
        "request 'bruteforce' starts a process"
      <|
        \game0 ->
            let
                ( serverId, server ) =
                    fromJust <| Game.getGateway game0

                servers1 =
                    Servers.insert serverId server (Game.getServers game0)

                game1 =
                    Game.setServers servers1 game0

                json =
                    """
                        { "process_id" : "id"
                        , "network_id" : "b"
                        , "target_ip" : "c"
                        , "file_id" : "d"
                        , "connection_id" : "e"
                        , "type" : "Cracker"
                        }
                    """
                        |> Decode.decodeString Decode.value
                        |> fromOk

                msg =
                    Game.ServersMsg <|
                        Servers.ServerMsg serverId <|
                            Servers.ProcessesMsg <|
                                Request <|
                                    BruteforceRequest ( OkCode, json )

                a =
                    game1
                        |> updateGame msg
                        |> Game.getServers
                        |> Servers.get serverId
                        |> fromJust
                        |> Servers.getProcesses
                        |> get "id"
                        |> Maybe.map (getState)
                        |> Expect.equal (Just Starting)
            in
                Expect.equal True True
    ]
