module Gen.Logs exposing (..)

import Time exposing (Time)
import Fuzz exposing (Fuzzer)
import Random.Pcg as Random exposing (Generator)
import Random.Pcg.Extra exposing (andMap)
import Gen.Utils exposing (..)
import Game.Servers.Logs.Models as Logs exposing (..)


--------------------------------------------------------------------------------
-- Fuzzers
--------------------------------------------------------------------------------


model : Fuzzer Model
model =
    fuzzer genModel


list : Fuzzer (List ( ID, Log ))
list =
    fuzzer genList


tuple : Fuzzer ( ID, Log )
tuple =
    fuzzer genTuple


id : Fuzzer ID
id =
    fuzzer genID


log : Fuzzer Log
log =
    fuzzer genLog


timestamp : Fuzzer Time
timestamp =
    fuzzer genTimestamp


status : Fuzzer Status
status =
    fuzzer genStatus


content : Fuzzer Content
content =
    fuzzer genContent


data : Fuzzer Data
data =
    fuzzer genData



--------------------------------------------------------------------------------
-- Generators
--------------------------------------------------------------------------------


genModel : Generator Model
genModel =
    Random.andThen (List.foldl (uncurry insert) initialModel >> Random.constant)
        genList


genList : Generator (List ( ID, Log ))
genList =
    Random.andThen (genTuple |> flip Random.list) (Random.int 1 10)


genTuple : Generator ( ID, Log )
genTuple =
    Random.map2 (,) genID genLog


genID : Generator ID
genID =
    unique


genLog : Generator Log
genLog =
    Random.map Log genTimestamp
        |> andMap genStatus
        |> andMap genContent


genTimestamp : Generator Time
genTimestamp =
    Random.float 1420070400 4102444799


genStatus : Generator Status
genStatus =
    [ Normal, RecentlyFound, RecentlyCreated ]
        |> List.map Random.constant
        |> Random.choices


genContent : Generator Content
genContent =
    Random.choices
        [ Random.constant Encrypted
        , Random.map Uncrypted genData
        ]


genData : Generator Data
genData =
    let
        customFormat =
            Random.map Just <| stringRange 0 32

        formats =
            customFormat
                :: List.map (Just >> Random.constant)
                    [ "Address logged in as user"
                    , "Logged into address"
                    , "Subject bounced connection from origin to remote"
                    , "File name downloaded by address"
                    , "File name downloaded from address"
                    ]

        toData str =
            case getContent <| new 0.0 Normal str of
                Uncrypted data ->
                    data

                Encrypted ->
                    Debug.crash "Wat?"
    in
        Random.map toData <| Random.choices formats
