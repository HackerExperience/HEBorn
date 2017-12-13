module Apps.LogViewer.Models exposing (..)

import Dict exposing (Dict)
import Game.Data as Game
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Logs.Models as Logs
import Apps.LogViewer.Menu.Models as Menu


type Sorting
    = DefaultSort


type alias Model =
    { menu : Menu.Model
    , filterText : String
    , filterFlags : List Never
    , filterCache : List Logs.ID
    , sorting : Sorting
    , expanded : List Logs.ID
    , editing : Dict.Dict Logs.ID String
    }


name : String
name =
    "Log Viewer"


title : Model -> String
title model =
    let
        filter =
            model.filterText

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
    { menu = Menu.initialMenu
    , filterText = ""
    , filterFlags = []
    , filterCache = []
    , sorting = DefaultSort
    , expanded = []
    , editing = Dict.empty
    }


isEntryExpanded : Logs.ID -> Model -> Bool
isEntryExpanded log model =
    List.member log model.expanded


toggleExpanded : Logs.ID -> Model -> Model
toggleExpanded id model =
    { model
        | expanded =
            if isEntryExpanded id model then
                List.filter ((/=) id) model.expanded
            else
                id :: model.expanded
    }


catchDataWhenFiltering : List Logs.ID -> Logs.ID -> Maybe Logs.ID
catchDataWhenFiltering filterCache log =
    if List.member log filterCache then
        Just log
    else
        Nothing


applyFilter : Model -> Logs.Model -> Logs.Model
applyFilter model logs =
    let
        filterer id log =
            if String.length model.filterText > 0 then
                catchDataWhenFiltering model.filterCache id
                    |> Maybe.map (always True)
                    |> Maybe.withDefault False
            else
                True
    in
        { logs | logs = Logs.filter filterer logs }


enterEditing : Game.Data -> Logs.ID -> Model -> Model
enterEditing data id model =
    let
        logs =
            data
                |> Game.getActiveServer
                |> Servers.getLogs

        model_ =
            case Dict.get id logs.logs of
                Just log ->
                    case Logs.getContent log of
                        Logs.NormalContent data ->
                            Just <| updateEditing id data.raw model

                        Logs.Encrypted ->
                            Nothing

                _ ->
                    Nothing
    in
        Maybe.withDefault model model_


updateEditing : Logs.ID -> String -> Model -> Model
updateEditing id value model =
    let
        editing_ =
            Dict.insert id value model.editing
    in
        { model | editing = editing_ }


toggleExpand : Logs.ID -> Model -> Model
toggleExpand id model =
    { model
        | expanded =
            if List.member id model.expanded then
                List.filter ((/=) id) model.expanded
            else
                id :: model.expanded
    }


leaveEditing : Logs.ID -> Model -> Model
leaveEditing id model =
    let
        editing_ =
            Dict.filter (\k _ -> k /= id) model.editing
    in
        { model | editing = editing_ }


getEdit : Logs.ID -> Model -> Maybe Logs.ID
getEdit id model =
    Dict.get id model.editing


updateTextFilter : Game.Data -> String -> Model -> Model
updateTextFilter data filter model =
    let
        filterer id log =
            case Logs.getContent log of
                Logs.NormalContent data ->
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
        { model
            | filterText = filter
            , filterCache = filterCache
        }
