module Gen.Logs exposing (..)

import Arithmetic exposing (isEven)
import Gen.Utils exposing (..)
import Game.Servers.Logs.Models exposing (..)


logID : Int -> LogID
logID seedInt =
    fuzz1 seedInt logIDSeed


logIDSeed : StringSeed
logIDSeed seed =
    smallStringSeed seed


content : Int -> String
content seedInt =
    fuzz1 seedInt contentSeed


contentSeed : StringSeed
contentSeed seed =
    smallStringSeed seed


stdLog : Int -> Log
stdLog seedInt =
    fuzz1 seedInt stdLogSeed


stdLogSeed : Seed -> ( Log, Seed )
stdLogSeed seed =
    let
        ( id, seed1 ) =
            logIDSeed seed

        ( content, seed2 ) =
            contentSeed seed1
    in
        ( stdLogArgs id content, seed2 )


stdLogArgs : LogID -> LogContent -> Log
stdLogArgs id content =
    LogEntry
        { id = id
        , content = content
        }


logsEmpty : Logs
logsEmpty =
    initialLogs


model : Int -> Logs
model seedInt =
    logs seedInt


log : Int -> Log
log seedInt =
    fuzz1 seedInt logSeed


logSeed : Seed -> ( Log, Seed )
logSeed seed =
    let
        ( result, seed_ ) =
            intSeed seed
    in
        if isEven result then
            stdLogSeed seed_
        else
            ( NoLog, seed_ )


logList : Int -> List Log
logList seedInt =
    fuzz1 seedInt logListSeed


logListSeed : Seed -> ( List Log, Seed )
logListSeed seed =
    let
        ( size, seed_ ) =
            intRangeSeed 1 100 seed

        list =
            List.range 1 size

        reducer =
            \_ ( logs, seed ) ->
                let
                    ( log, seed_ ) =
                        logSeed seed
                in
                    ( log :: logs, seed_ )
    in
        List.foldl reducer ( [], seed_ ) list


logs : Int -> Logs
logs seedInt =
    fuzz1 seedInt logsSeed


logsSeed : Seed -> ( Logs, Seed )
logsSeed seed =
    let
        ( logList, seed_ ) =
            logListSeed seed

        logs =
            -- TODO: remove this lambda after moving logs to the last param
            List.foldl (\log logs -> addLog logs log) logsEmpty logList
    in
        ( logs, seed_ )
