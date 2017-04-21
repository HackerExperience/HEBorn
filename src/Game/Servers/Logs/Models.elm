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


getLogContent : Log -> Maybe LogContent
getLogContent log =
    case log of
        LogEntry l ->
            Just l.content

        NoLog ->
            Nothing


getLogID : Log -> Maybe LogID
getLogID log =
    case log of
        LogEntry l ->
            Just l.id

        NoLog ->
            Nothing


addLog : Logs -> Log -> Logs
addLog logs log =
    case (getLogID log) of
        Just id ->
            Dict.insert id log logs

        Nothing ->
            logs


removeLog : Logs -> Log -> Logs
removeLog logs log =
    case (getLogID log) of
        Just id ->
            Dict.remove id logs

        Nothing ->
            logs


updateLog : Logs -> Log -> Logs
updateLog logs log =
    case log of
        LogEntry entry ->
            Utils.safeUpdateDict logs entry.id log

        NoLog ->
            logs
