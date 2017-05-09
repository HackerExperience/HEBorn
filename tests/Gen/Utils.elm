module Gen.Utils exposing (..)

import Random
import Random.Int
import Random.Float
import Random.String
import Random.Char


type alias Seed =
    Random.Seed


type alias StringSeed =
    Seed -> ( String, Seed )


listOfInt : Int -> Int -> List Int
listOfInt size seedInt =
    let
        seed =
            Random.initialSeed seedInt

        ( pace, seed1 ) =
            intSeed seed

        list =
            List.indexedMap
                (\i value -> (i + value + pace))
                (List.repeat size seedInt)
    in
        list


listOfSeed : Int -> Seed -> ( List Seed, Seed )
listOfSeed size seed =
    let
        ( base, seed1 ) =
            intSeed seed

        ( pace, seed2 ) =
            intSeed seed1

        -- todo: make me recursive
        list =
            List.map
                (\item ->
                    let
                        ( _, seed_ ) =
                            Random.step (Random.int 1 10) seed2
                    in
                        seed_
                )
                (List.repeat size base)
    in
        ( list, seed2 )


intSeed seed =
    Random.step
        (Random.Int.anyInt)
        seed


int seedInt =
    fuzz1 seedInt intSeed


intRangeSeed min max seed =
    Random.step
        (Random.int min max)
        seed


intRange min max seedInt =
    fuzz1 seedInt (intRangeSeed min max)


float seedInt =
    fuzz1 seedInt floatSeed


floatSeed seed =
    Random.step
        Random.Float.anyFloat
        seed


floatRange min max seedInt =
    fuzz1 seedInt (floatRangeSeed min max)


floatRangeSeed min max seed =
    Random.step
        (Random.float min max)
        seed


percentage : Int -> Float
percentage seedInt =
    fuzz1 seedInt percentageSeed


percentageSeed : Seed -> ( Float, Seed )
percentageSeed seed =
    floatRangeSeed 0 1 seed


smallStringSeed : StringSeed
smallStringSeed seed =
    stringSeed 1 64 seed


stringSeed : Int -> Int -> StringSeed
stringSeed min max seed =
    Random.step
        (Random.String.rangeLengthString min max Random.Char.english)
        seed


fuzz1 : Int -> (Seed -> ( a, Seed )) -> a
fuzz1 seedInt function =
    let
        seed0 =
            Random.initialSeed seedInt

        ( value, _ ) =
            function seed0
    in
        value


fuzz2 : Int -> (Seed -> ( a, b )) -> (b -> ( c, d )) -> ( a, c )
fuzz2 seedInt f1 f2 =
    let
        seed0 =
            Random.initialSeed seedInt

        ( v1, seed1 ) =
            f1 seed0

        ( v2, _ ) =
            f2 seed1
    in
        ( v1, v2 )


fuzz3 :
    Int
    -> (Seed -> ( a, b ))
    -> (b -> ( c, d ))
    -> (d -> ( e, f ))
    -> ( a, c, e )
fuzz3 seedInt f1 f2 f3 =
    let
        seed0 =
            Random.initialSeed seedInt

        ( v1, seed1 ) =
            f1 seed0

        ( v2, seed2 ) =
            f2 seed1

        ( v3, _ ) =
            f3 seed2
    in
        ( v1, v2, v3 )


fuzz4 :
    Int
    -> (Seed -> ( a, b ))
    -> (b -> ( c, d ))
    -> (d -> ( e, f ))
    -> (f -> ( g, h ))
    -> ( a, c, e, g )
fuzz4 seedInt f1 f2 f3 f4 =
    let
        seed0 =
            Random.initialSeed seedInt

        ( v1, seed1 ) =
            f1 seed0

        ( v2, seed2 ) =
            f2 seed1

        ( v3, seed3 ) =
            f3 seed2

        ( v4, _ ) =
            f4 seed3
    in
        ( v1, v2, v3, v4 )
