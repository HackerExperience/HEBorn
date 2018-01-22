module Game.Account.IntegrationTest exposing (all, passwordAcquired, replyUnlocked)

import Dict exposing (Dict)
import Expect
import Fuzz exposing (tuple, tuple3)
import Test exposing (Test, describe)
import Utils.React as React exposing (React)
import Core.Messages as Core
import Json.Decode as Decode
import TestUtils exposing (fuzz, gameDispatcher, fromJust, toValue, applyEvent)
import Requests.Types exposing (Code(OkCode))
import Gen.Processes as GenProcesses
import Gen.Game as GenGame
import Driver.Websocket.Channels exposing (Channel(..))
import Game.Messages as Game
import Game.Models as Game
import Game.Account.Messages as Account
import Game.Account.Models as Account
import Game.Storyline.Models as Story
import Game.Storyline.Emails.Models as Emails
import Game.Storyline.Emails.Contents as Emails
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
    [ passwordAcquired
    , replyUnlocked
    ]


passwordAcquired : Test
passwordAcquired =
    fuzz
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
                    """
                        { "server_ip": "phoebe"
                        , "password": "asdfasdf"
                        , "network_id": "id"
                        , "process_id": "id"
                        , "gateway_ip": "ip"
                        }
                        """
            in
                game
                    |> applyEvent name json channel
                    |> Game.getAccount
                    |> Account.getDatabase
                    |> getHackedServers
                    |> Dict.get ( "id", "phoebe" )
                    |> Maybe.map getPassword
                    |> Expect.equal (Just "asdfasdf")


replyUnlocked : Test
replyUnlocked =
    fuzz
        GenGame.model
        "event 'story_email_reply_unlocked' inserts the password"
    <|
        \game ->
            let
                ( serverId, server ) =
                    fromJust "story_email_reply_unlocked fetching gateway" <|
                        Game.getGateway game

                -- building event
                channel =
                    AccountChannel ""

                name =
                    "story_email_reply_unlocked"

                json =
                    """
                        { "contact_id": "kress"
                        , "replies":
                            [ { "id": "helloworld"
                              , "meta": { "something": "itriedsohardandgotsofar" }
                            } ]
                        }
                        """
            in
                game
                    |> applyEvent name json channel
                    |> Game.getStory
                    |> Story.getEmails
                    |> Emails.getPerson ("kress")
                    |> Maybe.map Emails.getAvailableReplies
                    |> Expect.equal
                        (Just
                            [ Emails.HelloWorld "itriedsohardandgotsofar"
                            ]
                        )
