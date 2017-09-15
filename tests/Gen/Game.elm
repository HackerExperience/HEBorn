module Gen.Game exposing (..)

import Fuzz exposing (Fuzzer)
import Random.Pcg exposing (Generator, andThen, map, map2, list, int)
import Game.Account.Models as Account
import Game.Meta.Models as Meta
import Game.Storyline.Models as Story
import Game.Models exposing (..)
import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Gen.Servers
import Gen.Utils exposing (..)


--------------------------------------------------------------------------------
-- Fuzzers
--------------------------------------------------------------------------------


model : Fuzzer Model
model =
    fuzzer genModel



--------------------------------------------------------------------------------
-- Generators
--------------------------------------------------------------------------------


genModel : Generator Model
genModel =
    let
        genPairs =
            map2 (,) Gen.Servers.genServerID Gen.Servers.genServer

        genServers =
            andThen (flip list genPairs) (int 8 10)

        insertServer ( id, server ) game =
            let
                isGateway =
                    case server.ownership of
                        Servers.GatewayOwnership _ ->
                            True

                        _ ->
                            False

                servers =
                    Servers.insert id server game.servers

                account =
                    if isGateway then
                        Account.insertServer id game.account
                    else
                        game.account
            in
                { game
                    | servers = servers
                    , account = account
                }

        construct servers =
            let
                game =
                    { account =
                        Account.initialModel "" "" ""
                    , servers =
                        Servers.initialModel
                    , meta =
                        Meta.initialModel
                    , story =
                        Story.initialModel
                    , config =
                        { apiHttpUrl = ""
                        , apiWsUrl = ""
                        , version = "test"
                        }
                    }
            in
                List.foldl insertServer game servers
    in
        map construct genServers
