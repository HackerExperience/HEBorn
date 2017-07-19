module Gen.Game exposing (..)

import Fuzz exposing (Fuzzer)
import Random.Pcg exposing (Generator, map)
import Game.Account.Models as Account
import Game.Meta.Models as Meta
import Game.Web.Models as Web
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
            , web = Web.initialModel
            , config =
                { apiHttpUrl = ""
                , apiWsUrl = ""
                , version = "test"
                }
            }
        )
        Gen.Servers.genModel
