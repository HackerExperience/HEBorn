module Game.Servers.Processes.IntegrationTest exposing (all)

import Expect
import Fuzz exposing (tuple, tuple3)
import Test exposing (Test, describe)
import Utils.React as React exposing (React)
import Core.Messages as Core
import Json.Decode as Decode
import TestUtils exposing (fuzz, updateGame, gameDispatcher, fromJust, applyEvent)
import Requests.Types exposing (Code(OkCode))
import Gen.Processes as GenProcesses
import Gen.Game as GenGame
import Driver.Websocket.Channels exposing (Channel(..))
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
        ]



--------------------------------------------------------------------------------
-- Event Tests
--------------------------------------------------------------------------------


eventTests : List Test
eventTests =
    [ fuzz
        GenGame.model
        "event 'process_created' creates a new process"
      <|
        \game ->
            let
                ( serverId, server ) =
                    fromJust "process_created fetching gateway" <|
                        Game.getGateway game

                -- building event
                channel =
                    ServerChannel serverId

                name =
                    "process_created"

                json =
                    """
                        { "type" : "cracker_bruteforce"
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
            in
                game
                    |> applyEvent name json channel
                    |> Game.getServers
                    |> Servers.get serverId
                    |> fromJust "process.started fetching serverId"
                    |> Servers.getProcesses
                    |> get "id"
                    |> Maybe.map (getType)
                    |> Expect.equal (Just Cracker)
    , fuzz
        (tuple ( GenGame.model, GenProcesses.fullProcess ))
        "event 'process_completed' concludes a process"
      <|
        \( game0, process0 ) ->
            let
                ( serverId, server0 ) =
                    fromJust "process_completed fetching gateway" <|
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
                    ServerChannel serverId

                name =
                    "process_completed"

                json =
                    """
                        { "process_id": "id" }
                        """
            in
                game1
                    |> applyEvent name json channel
                    |> Game.getServers
                    |> Servers.get serverId
                    |> fromJust "process.conclusion fetching serverId"
                    |> Servers.getProcesses
                    |> get "id"
                    |> Maybe.map getState
                    |> Expect.equal (Just <| Succeeded)
    , fuzz
        (tuple ( GenGame.model, GenProcesses.fullProcess ))
        "event 'bruteforce_failed' concludes a process"
      <|
        \( game0, process0 ) ->
            let
                ( serverId, server0 ) =
                    fromJust "bruteforce_failed fetching gateway" <|
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
                    ServerChannel serverId

                name =
                    "bruteforce_failed"

                json =
                    """
                        { "process_id": "id"
                        , "reason": "any"
                        }
                        """
            in
                game1
                    |> applyEvent name json channel
                    |> Game.getServers
                    |> Servers.get serverId
                    |> fromJust "bruteforce_failed fetching serverId"
                    |> Servers.getProcesses
                    |> get "id"
                    |> Maybe.map getState
                    |> Expect.equal (Just <| Failed Unknown)
    ]
