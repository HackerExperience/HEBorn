module Game.Servers.Logs.Models exposing (..)

import Dict
import Utils
import Task
import Time exposing (Time, now)
import Game.Shared exposing (ID)


type alias LogID =
    ID


type alias LogContent =
    String


type alias LogTimestamp =
    Time


type alias LogData =
    { id : LogID
    , content : LogContent
    , timestamp : LogTimestamp
    }


type Log
    = LogEntry LogData
    | NoLog


type alias Logs =
    Dict.Dict LogID Log


initialLogs : Logs
initialLogs =
    Dict.empty


getLogByID : LogID -> Logs -> Log
getLogByID id logs =
    case Dict.get id logs of
        Just log ->
            log

        Nothing ->
            NoLog


logExists : LogID -> Logs -> Bool
logExists id logs =
    Dict.member id logs


getLogTimestamp : Log -> Maybe LogTimestamp
getLogTimestamp log =
    case log of
        LogEntry l ->
            Just l.timestamp

        NoLog ->
            Nothing


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


addLog : Log -> Logs -> Logs
addLog log logs =
    case (getLogID log) of
        Just id ->
            Dict.insert id log logs

        Nothing ->
            logs


removeLog : Log -> Logs -> Logs
removeLog log logs =
    case (getLogID log) of
        Just id ->
            Dict.remove id logs

        Nothing ->
            logs


updateLog : Log -> Logs -> Logs
updateLog log logs =
    case log of
        LogEntry entry ->
            Utils.safeUpdateDict logs entry.id log

        NoLog ->
            logs
