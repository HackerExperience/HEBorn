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


id : Fuzzer ID
id =
    fuzzer genId


ip : Fuzzer IP
ip =
    fuzzer genIp



--------------------------------------------------------------------------------
-- Generators
--------------------------------------------------------------------------------


genNip : Generator NIP
genNip =
    map2 (,) genId genIp


genId : Generator ID
genId =
    unique


genIp : Generator IP
genIp =
    unique
