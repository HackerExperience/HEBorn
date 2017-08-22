module Gen.Game exposing (..)

import Fuzz exposing (Fuzzer)
import Random.Pcg exposing (Generator, map)
import Game.Account.Models as Account
import Game.Meta.Models as Meta
import Game.Storyline.Models as Story
import Game.Models exposing (..)
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
    map
        (\servers ->
            { account = Account.initialModel "" "" ""
            , servers = servers
            , meta = Meta.initialModel
            , story = Story.initialModel
            , config =
                { apiHttpUrl = ""
                , apiWsUrl = ""
                , version = "test"
                }
            }
        )
        Gen.Servers.genModel
