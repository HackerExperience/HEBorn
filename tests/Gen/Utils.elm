module Gen.Utils exposing (..)


import Random
import Random.String
import Random.Char


type alias StringSeed =
    Random.Seed -> (String, Random.Seed)


smallStringSeed : StringSeed
smallStringSeed seed =
    stringSeed 1 64 seed


stringSeed : Int -> Int -> StringSeed
stringSeed min max seed =
    Random.step
        (Random.String.rangeLengthString min max Random.Char.english) seed


fuzz1 seedInt function =
    let
        seed = Random.initialSeed seedInt
        (value, _) = function seed
    in
        value


fuzz2 seedInt f1 f2 =
    let
        seed0 = Random.initialSeed seedInt
        (v1, seed1) = f1 seed0
        (v2, _) = f2 seed1
    in
        (v1, v2)


fuzz3 seedInt f1 f2 f3 =
    let
        seed0 = Random.initialSeed seedInt
        (v1, seed1) = f1 seed0
        (v2, seed2) = f2 seed1
        (v3, _) = f3 seed2
    in
        (v1, v2, v3)


