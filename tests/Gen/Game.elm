module Gen.Game exposing (..)

import Gen.Servers
import Fuzz exposing (Fuzzer)
import Random.Pcg exposing (Generator, map)
import Game.Account.Models exposing (..)
import Game.Meta.Models exposing (..)
import Game.Models exposing (..)
import Game.Network.Models exposing (..)
import Gen.Utils exposing (..)


--------------------------------------------------------------------------------
-- Fuzzers
--------------------------------------------------------------------------------


model : Fuzzer GameModel
model =
    fuzzer genModel



--------------------------------------------------------------------------------
-- Generators
--------------------------------------------------------------------------------


genModel : Generator GameModel
genModel =
    map
        (\servers ->
            { account = initialAccountModel
            , servers = servers
            , network = initialNetworkModel
            , meta = initialMetaModel "" "" ""
            }
        )
        Gen.Servers.genModel
