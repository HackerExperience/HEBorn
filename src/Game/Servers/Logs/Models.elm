module Game.Servers.Logs.Models exposing (..)

import Dict
import Utils
import Game.Shared exposing (ID)


type alias LogID =
    ID


type alias LogContent =
    String


type alias LogData =
    { id : LogID
    , content : LogContent
    }

type Log
    = LogEntry LogData
    | NoLog


type alias Logs =
    Dict.Dict LogID Log


initialLogs : Logs
initialLogs =
    Dict.empty

invalidLogContent : LogContent
invalidLogContent =
    ""


invalidLogID : LogID
invalidLogID =
    ""


getLogByID : Logs -> LogID -> Log
getLogByID logs id =
    case Dict.get id logs of
        Just log ->
            log

        Nothing ->
            NoLog

logExists : Logs -> LogID -> Bool
logExists logs id =
    Dict.member id logs


getLogContent : Log -> LogContent
getLogContent log =
    case log of
        LogEntry l ->
            l.content
        NoLog ->
            invalidLogContent

getLogID : Log -> LogID
getLogID log =
    case log of
        LogEntry l ->
            l.id

        NoLog ->
            invalidLogID

removeLog : Logs -> Log -> Logs
removeLog logs log =
    Dict.remove (getLogID log) logs


updateLog : Logs -> Log -> Logs
updateLog logs log =
    case log of
        LogEntry entry ->
           Utils.safeUpdateDict logs entry.id log
        NoLog ->
            logs

