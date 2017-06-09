module Gen.Utils exposing (..)

import Shrink
import Random.Pcg.Char as RandomChar exposing (english)
import Random.Pcg.Extra as RandomExtra exposing (rangeLengthList)
import Random.Pcg.String as RandomString exposing (rangeLengthString)
import Fuzz exposing (Fuzzer)
import Random.Pcg as Random exposing (Generator, constant, map, choices)


unique : Generator String
unique =
    rangeLengthString 64 64 english


stringRange : Int -> Int -> Generator String
stringRange min max =
    rangeLengthString min max english


fuzzer : Generator a -> Fuzzer a
fuzzer f =
    Fuzz.custom f Shrink.noShrink


string : Int -> Generator String
string length =
    RandomString.string length english


listRange : Int -> Int -> Generator a -> Generator (List a)
listRange min max =
    rangeLengthList min max


percentage : Generator Float
percentage =
    Random.float 0 1


maybe : Generator a -> Generator (Maybe a)
maybe a =
    Random.choices
        [ Random.constant Nothing
        , Random.map Just a
        ]
