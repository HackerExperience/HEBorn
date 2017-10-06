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
import Events.Servers exposing (Event(ProcessesEvent))
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
        GenGame.model
        "event 'processes.started' creates a new process"
      <|
        \game ->
            let
                ( serverId, server ) =
                    fromJust "process.started fetching gateway" <|
                        Game.getGateway game

                -- building event
                channel =
                    ServerChannel server.nip

                name =
                    "processes.started"

                json =
                    toValue
                        """
                        { "type" : "Cracker"
                        , "access" :
                            { "origin_ip" : "id"
                            , "priority" : 3
                            , "usage" :
                                { "cpu" :
                                    { "percentage" : 0.0
                                    , "absolute" : 1
                                    }
                                , "mem" :
                                    { "percentage" : 0.0
                                    , "absolute" : 1
                                    }
                                , "down" :
                                    { "percentage" : 0.0
                                    , "absolute" : 1
                                    }
                                , "up" :
                                    { "percentage" : 0.0
                                    , "absolute" : 1
                                    }
                                }
                            , "connection_id" : "id"
                            }
                        , "state" : "running"
                        , "file" :
                            { "id" : "id"
                            , "version" : 0.0
                            , "name" : "process"
                            }
                        , "progress" :
                            { "percentage" : 0.0
                            , "creation_date" : 0.0
                            , "completion_date" : 0.0
                            }
                        , "network_id" : "id"
                        , "target_ip" : "id"
                        , "process_id" : "id"
                        }
                        """

                msg =
                    Events.handler channel name json
                        |> fromJust ""
                        |> Game.Event
            in
                game
                    |> updateGame msg
                    |> Game.getServers
                    |> Servers.get serverId
                    |> fromJust "process.started fetching serverId"
                    |> Servers.getProcesses
                    |> get "id"
                    |> Maybe.map (getType)
                    |> Expect.equal (Just Cracker)
    , fuzz
        (tuple ( GenGame.model, GenProcesses.fullProcess ))
        "event 'processes.conclusion' concludes a process"
      <|
        \( game0, process0 ) ->
            let
                ( serverId, server0 ) =
                    fromJust "process.conclusion fetching gateway" <|
                        Game.getGateway game0

                process1 =
                    { process0 | state = Running }

                processes0 =
                    Servers.getProcesses server0

                processes1 =
                    insert "id" process1 processes0

                server1 =
                    Servers.setProcesses processes1 server0

                servers1 =
                    Servers.insert serverId server1 (Game.getServers game0)

                game1 =
                    Game.setServers servers1 game0

                -- building event
                channel =
                    ServerChannel server1.nip

                name =
                    "processes.conclusion"

                json =
                    toValue
                        """
                        { "process_id": "id" }
                        """

                msg =
                    Events.handler channel name json
                        |> fromJust ""
                        |> Game.Event
            in
                game1
                    |> updateGame msg
                    |> Game.getServers
                    |> Servers.get serverId
                    |> fromJust "process.conclusion fetching serverId"
                    |> Servers.getProcesses
                    |> get "id"
                    |> Maybe.map getState
                    |> Expect.equal (Just <| Succeeded)
    , fuzz
        (tuple ( GenGame.model, GenProcesses.fullProcess ))
        "event 'processes.bruteforce_failed' concludes a process"
      <|
        \( game0, process0 ) ->
            let
                ( serverId, server0 ) =
                    fromJust "process.bruteforce_failed fetching gateway" <|
                        Game.getGateway game0

                process1 =
                    { process0 | state = Running }

                processes0 =
                    Servers.getProcesses server0

                processes1 =
                    insert "id" process1 processes0

                server1 =
                    Servers.setProcesses processes1 server0

                servers1 =
                    Servers.insert serverId server1 (Game.getServers game0)

                game1 =
                    Game.setServers servers1 game0

                -- building event
                channel =
                    ServerChannel server1.nip

                name =
                    "processes.bruteforce_failed"

                json =
                    toValue
                        """
                        { "process_id": "id"
                        , "reason": "any"
                        }
                        """

                msg =
                    Events.handler channel name json
                        |> fromJust ""
                        |> Game.Event
            in
                game1
                    |> updateGame msg
                    |> Game.getServers
                    |> Servers.get serverId
                    |> fromJust "process.bruteforce_failed fetching serverId"
                    |> Servers.getProcesses
                    |> get "id"
                    |> Maybe.map getState
                    |> Expect.equal (Just <| Failed Unknown)
    ]



--------------------------------------------------------------------------------
-- Request Tests
--------------------------------------------------------------------------------


requestTests : List Test
requestTests =
    [ fuzz
        (tuple ( GenGame.model, GenProcesses.fullProcess ))
        "request 'bruteforce' replaces an optimistic process"
      <|
        \( game0, process0 ) ->
            let
                ( serverId, server0 ) =
                    fromJust "bruteforce fetching gateway" <|
                        Game.getGateway game0

                process1 =
                    { process0 | state = Starting }

                processes0 =
                    Servers.getProcesses server0

                ( oldId, processes1 ) =
                    insertOptimistic process1 processes0

                server1 =
                    Servers.setProcesses processes1 server0

                servers1 =
                    Servers.insert serverId server1 (Game.getServers game0)

                game1 =
                    Game.setServers servers1 game0

                json =
                    toValue
                        """
                        { "type" : "Cracker"
                        , "access" :
                            { "origin_ip" : "id"
                            , "priority" : 3
                            , "usage" :
                                { "cpu" :
                                    { "percentage" : 0.1
                                    , "absolute" : 1
                                    }
                                , "mem" :
                                    { "percentage" : 0.0
                                    , "absolute" : 1
                                    }
                                , "down" :
                                    { "percentage" : 0.0
                                    , "absolute" : 1
                                    }
                                , "up" :
                                    { "percentage" : 0.0
                                    , "absolute" : 1
                                    }
                                }
                            , "connection_id" : "id"
                            }
                        , "state" : "running"
                        , "file" :
                            { "id" : "id"
                            , "version" : 0.0
                            , "name" : "process"
                            }
                        , "progress" :
                            { "percentage" : 0.0
                            , "creation_date" : 0.0
                            , "completion_date" : 0.0
                            }
                        , "network_id" : "id"
                        , "target_ip" : "id"
                        , "process_id" : "id"
                        }
                        """

                msg =
                    Game.ServersMsg <|
                        Servers.ServerMsg serverId <|
                            Servers.ProcessesMsg <|
                                Request <|
                                    BruteforceRequest oldId ( OkCode, json )
            in
                game1
                    |> updateGame msg
                    |> Game.getServers
                    |> Servers.get serverId
                    |> fromJust "process.bruteforce fetching serverId"
                    |> Servers.getProcesses
                    |> get "id"
                    |> Maybe.map (getState)
                    |> Expect.equal (Just Running)
    ]
