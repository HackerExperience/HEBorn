module Gen.Network exposing (..)

import Fuzz exposing (Fuzzer)
import Random.Pcg exposing (Generator, map2)
import Gen.Utils exposing (..)
import Game.Network.Types exposing (..)


--------------------------------------------------------------------------------
-- Fuzzers
--------------------------------------------------------------------------------


nip : Fuzzer NIP
nip =
    fuzzer genNip



--------------------------------------------------------------------------------
-- Generators
--------------------------------------------------------------------------------


genNip : Generator NIP
genNip =
    map2 (,) unique unique
