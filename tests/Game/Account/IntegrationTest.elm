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
import Events.Events as Events exposing (Event(..))
import Game.Messages as Game
import Game.Models as Game
import Game.Account.Messages as Account
import Game.Account.Models as Account
import Game.Servers.Messages as Servers
import Game.Servers.Models as Servers
import Game.Account.Database.Models exposing (..)


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
        "event 'server_password_acquired' inserts the password"
      <|
        \game ->
            let
                ( serverId, server ) =
                    fromJust "server_password_acquired fetching gateway" <|
                        Game.getGateway game

                -- building event
                channel =
                    AccountChannel ""

                name =
                    "server_password_acquired"

                json =
                    toValue
                        """
                        { "server_ip": "phoebe"
                        , "password": "asdfasdf"
                        , "network_id": "id"
                        , "process_id": "id"
                        , "gateway_ip": "ip"
                        }
                        """

                msg =
                    Events.events channel name json
                        |> fromJust ""
                        |> Game.Event
            in
                game
                    |> updateGame msg
                    |> Game.getAccount
                    |> Account.getDatabase
                    |> getHackedServers
                    |> Dict.get ( "id", "phoebe" )
                    |> Maybe.map getPassword
                    |> Expect.equal (Just "asdfasdf")
    ]
