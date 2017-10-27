module Apps.LogViewer.Models exposing (..)

import Dict exposing (Dict)
import Game.Data as Game
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Logs.Models as Logs
import Apps.LogViewer.Menu.Models as Menu


type Sorting
    = DefaultSort


type alias LogViewer =
    { filterText : String
    , filterFlags : List Never
    , filterCache : List Logs.ID
    , sorting : Sorting
    , expanded : List Logs.ID
    , editing : Dict.Dict Logs.ID String
    }


type alias Model =
    { app : LogViewer
    , menu : Menu.Model
    }



-- TODO: rewrite this model's functions


name : String
name =
    "Log Viewer"


title : Model -> String
title ({ app } as model) =
    let
        filter =
            app.filterText

        posfix =
            if String.length filter > 12 then
                Just <| ": \"" ++ (String.left 10 filter) ++ "[...]\""
            else if String.length filter > 0 then
                Just <| ": \"" ++ filter ++ "\""
            else
                Nothing
    in
        posfix
            |> Maybe.map ((++) name)
            |> Maybe.withDefault name


icon : String
icon =
    "logvw"


initialModel : Model
initialModel =
    { app = initialLogViewer
    , menu = Menu.initialMenu
    }


initialLogViewer : LogViewer
initialLogViewer =
    { filterText = ""
    , filterFlags = []
    , filterCache = []
    , sorting = DefaultSort
    , expanded = []
    , editing = Dict.empty
    }


isEntryExpanded : Logs.ID -> LogViewer -> Bool
isEntryExpanded log app =
    List.member log app.expanded


toggleExpanded : Logs.ID -> LogViewer -> LogViewer
toggleExpanded id app =
    { app
        | expanded =
            if isEntryExpanded id app then
                List.filter ((/=) id) app.expanded
            else
                id :: app.expanded
    }


catchDataWhenFiltering : List Logs.ID -> Logs.ID -> Maybe Logs.ID
catchDataWhenFiltering filterCache log =
    if List.member log filterCache then
        Just log
    else
        Nothing


applyFilter : LogViewer -> Logs.Model -> Dict Logs.ID Logs.Log
applyFilter app =
    let
        filterer id log =
            if String.length app.filterText > 0 then
                catchDataWhenFiltering app.filterCache id
                    |> Maybe.map (always True)
                    |> Maybe.withDefault False
            else
                True
    in
        Logs.filter filterer


enterEditing : Game.Data -> Logs.ID -> Model -> Model
enterEditing data id ({ app } as model) =
    let
        logs =
            data
                |> Game.getActiveServer
                |> Servers.getLogs

        app_ =
            case Dict.get id logs of
                Just log ->
                    case Logs.getContent log of
                        Logs.Uncrypted data ->
                            Just <| updateEditing id data.raw app

                        Logs.Encrypted ->
                            Nothing

                _ ->
                    Nothing
    in
        app_
            |> Maybe.andThen (\v -> Just { model | app = v })
            |> Maybe.withDefault model


updateEditing : Logs.ID -> String -> LogViewer -> LogViewer
updateEditing id value app =
    let
        editing_ =
            Dict.insert id value app.editing
    in
        { app | editing = editing_ }


toggleExpand : Logs.ID -> LogViewer -> LogViewer
toggleExpand id app =
    { app
        | expanded =
            if List.member id app.expanded then
                List.filter ((/=) id) app.expanded
            else
                id :: app.expanded
    }


leaveEditing : Logs.ID -> LogViewer -> LogViewer
leaveEditing id app =
    let
        editing_ =
            Dict.filter (\k _ -> k /= id) app.editing
    in
        { app | editing = editing_ }


getEdit : Logs.ID -> LogViewer -> Maybe Logs.ID
getEdit id app =
    Dict.get id app.editing


updateTextFilter : Game.Data -> String -> LogViewer -> LogViewer
updateTextFilter data filter app =
    let
        filterer id log =
            case Logs.getContent log of
                Logs.Uncrypted data ->
                    String.contains filter data.raw

                Logs.Encrypted ->
                    False

        filterCache =
            data
                |> Game.getActiveServer
                |> Servers.getLogs
                |> Logs.filter filterer
                |> Dict.keys
    in
        { app
            | filterText = filter
            , filterCache = filterCache
        }
