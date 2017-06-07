module Apps.LogViewer.Models exposing (..)

import Dict
import Utils exposing (andThenWithDefault)
import Game.Servers.Models as Servers
    exposing
        ( ServerID
        , Servers
        , Server(..)
        , getServerByID
        , localhostServerID
        , getLogs
        )
import Game.Servers.Logs.Models as Logs exposing (..)
import Apps.LogViewer.Menu.Models as Menu


type alias LogViewer =
    { filtering : String
    , filterCache : List ID
    , expanded : List ID
    , editing : Dict.Dict ID String
    }


type alias Model =
    { app : LogViewer
    , menu : Menu.Model
    }


name : String
name =
    "Log Viewer"


title : Model -> String
title ({ app } as model) =
    let
        filter =
            app.filtering

        posfix =
            if (String.length filter) > 12 then
                Just (": \"" ++ (String.left 10 filter) ++ "[...]\"")
            else if (String.length filter) > 0 then
                Just (": \"" ++ filter ++ "\"")
            else
                Nothing
    in
        andThenWithDefault (\posfix -> name ++ posfix) name posfix


icon : String
icon =
    "logvw"


isEntryExpanded : LogViewer -> ID -> Bool
isEntryExpanded app log =
    List.member log app.expanded


toggleExpanded : LogViewer -> ID -> LogViewer
toggleExpanded app log =
    { app
        | expanded =
            if (isEntryExpanded app log) then
                List.filter ((/=) log) app.expanded
            else
                log :: app.expanded
    }


initialModel : Model
initialModel =
    { app = initialLogViewer
    , menu = Menu.initialMenu
    }


initialLogViewer : LogViewer
initialLogViewer =
    { filtering = ""
    , filterCache = []
    , expanded = []
    , editing = Dict.empty
    }


catchDataWhenFiltering : List ID -> Log -> Maybe StdData
catchDataWhenFiltering filterCache log =
    case log of
        StdLog logData ->
            if (List.member logData.id filterCache) then
                Just logData
            else
                Nothing

        NoLog ->
            Nothing


catchData : Log -> Maybe StdData
catchData log =
    case log of
        StdLog logData ->
            Just logData

        NoLog ->
            Nothing


applyFilter : LogViewer -> Logs -> List StdData
applyFilter app logs =
    logs
        |> Dict.values
        |> List.filterMap
            (if ((String.length app.filtering) > 0) then
                catchDataWhenFiltering app.filterCache
             else
                catchData
            )


getLogs : LogViewer -> Servers -> Logs
getLogs app servers =
    let
        server =
            getServerByID servers "localhost"
    in
        Maybe.withDefault
            initialLogs
            (Servers.getLogs server)


enterEditing : Servers -> Model -> ID -> Model
enterEditing servers ({ app } as model) logId =
    let
        logs =
            getLogs app servers

        log =
            Dict.get logId logs

        app_ =
            (case log of
                Just (StdLog log) ->
                    Just (updateEditing app log.id log.raw)

                _ ->
                    Nothing
            )
    in
        andThenWithDefault
            (\v -> { model | app = v })
            model
            app_


updateEditing : LogViewer -> ID -> String -> LogViewer
updateEditing app logId value =
    let
        editing_ =
            Dict.insert logId value app.editing
    in
        { app | editing = editing_ }


toggleExpand : LogViewer -> ID -> LogViewer
toggleExpand app logId =
    { app
        | expanded =
            if (List.member logId app.expanded) then
                List.filter ((/=) logId) app.expanded
            else
                logId :: app.expanded
    }


leaveEditing : LogViewer -> ID -> LogViewer
leaveEditing app logId =
    let
        editing_ =
            Dict.filter (\k _ -> k /= logId) app.editing
    in
        { app | editing = editing_ }


getEdit : LogViewer -> ID -> Maybe String
getEdit app logId =
    Dict.get logId app.editing


logFilterMapFun : String -> Log -> Maybe ID
logFilterMapFun filter log =
    case log of
        NoLog ->
            Nothing

        StdLog data ->
            if (String.contains filter data.raw) then
                Just data.id
            else
                Nothing


updateFilter : LogViewer -> Servers -> String -> LogViewer
updateFilter app servers newFilter =
    let
        newFilterCache =
            getLogs app servers
                |> Dict.values
                |> List.filterMap
                    (logFilterMapFun newFilter)
    in
        { app
            | filtering = newFilter
            , filterCache = newFilterCache
        }
