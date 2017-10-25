module Gen.Game exposing (..)

import Fuzz exposing (Fuzzer)
import Random.Pcg exposing (Generator, andThen, map, map2, list, int)
import Game.Account.Models as Account
import Game.Meta.Models as Meta
import Game.Storyline.Models as Story
import Game.Web.Models as Web
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
        game =
            { account =
                Account.initialModel "" "" ""
            , servers =
                Servers.initialModel
            , meta =
                Meta.initialModel
            , story =
                Story.initialModel
            , web =
                Web.initialModel
            , config =
                { apiHttpUrl = ""
                , apiWsUrl = ""
                , version = "test"
                }
            }

        genPairs =
            map2 (,) Gen.Servers.genServerCId

        genGatewayServer =
            genPairs Gen.Servers.genGatewayServer

        genEndpointServer =
            genPairs Gen.Servers.genEndpointServer

        genServers =
            map2 (\gate end -> [ gate, end ])
                genGatewayServer
                genEndpointServer

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
                        Account.insertGateway id game.account
                    else
                        game.account
            in
                { game
                    | servers = servers
                    , account = account
                }
    in
        map (List.foldl insertServer game) genServers
