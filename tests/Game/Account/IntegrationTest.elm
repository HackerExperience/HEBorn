module Game.Account.IntegrationTest exposing (all)

import Dict exposing (Dict)
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
import Game.Account.Messages as Account
import Game.Account.Models as Account
import Game.Servers.Messages as Servers
import Game.Servers.Models as Servers


all : Test
all =
    describe "account integration tests"
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
        "event 'database.server_password_acquired' inserts the password"
      <|
        \game ->
            let
                ( serverId, server ) =
                    fromJust <| Game.getGateway game

                -- building event
                channel =
                    AccountChannel

                context =
                    Just serverId

                name =
                    "database.server_password_acquired"

                json =
                    toValue
                        """
                        { "server_ip": "phoebe"
                        , "password": "asdfasdf"
                        , "network_id": "id"
                        , "process_id": "id"
                        , "gateway_id": "id"
                        }
                        """

                msg =
                    Events.handler channel context name json
                        |> fromJust
                        |> Game.Event
            in
                game
                    |> updateGame msg
                    |> Game.getAccount
                    |> Account.getDatabase
                    |> .servers
                    |> Dict.get ( "id", "phoebe" )
                    |> Maybe.map (always "found")
                    |> Expect.equal (Just "found")
    ]
