module Apps.LogFlix.Models exposing (..)

import Dict exposing (Dict)
import Game.Data as Game
import Game.Servers.Models as Servers exposing (Server)
import Game.LogStream.Models as LogStream
import Apps.LogFlix.Menu.Models as Menu


type Sorting
    = DefaultSort
    | ByType


type alias Model =
    { menu : Menu.Model
    , filterText : String
    , filterFlags : List Never
    , filterCache : List LogStream.Id
    , sorting : Sorting
    , selected : MainTab
    }


type MainTab
    = TabAll
    | TabSimple


name : String
name =
    "LogFlix"


title : Model -> String
title model =
    "LogFlix"


icon : String
icon =
    "logfl"


windowInitSize : ( Float, Float )
windowInitSize =
    ( 600, 600 )


initialModel : Model
initialModel =
    { menu = Menu.initialMenu
    , filterText = ""
    , filterFlags = []
    , filterCache = []
    , sorting = DefaultSort
    , selected = TabAll
    }


tabToString : MainTab -> String
tabToString tab =
    case tab of
        TabAll ->
            "All"

        TabSimple ->
            "Simple"


typeToString : LogStream.Log -> String
typeToString log =
    case log.type_ of
        LogStream.None ->
            ""

        LogStream.Request ->
            "Request"

        LogStream.Join ->
            "Join"

        LogStream.JoinAccount ->
            "JoinAccount"

        LogStream.JoinServer ->
            "JoinServer"

        LogStream.Error ->
            "Error"

        LogStream.Receive ->
            "Receive"

        LogStream.Event ->
            "Event"

        LogStream.Other ->
            "Other"


catchDataWhenFiltering : List LogStream.Id -> LogStream.Id -> Maybe LogStream.Id
catchDataWhenFiltering filterCache log =
    if List.member log filterCache then
        Just log
    else
        Nothing


applyFilter : Model -> LogStream.LogStream -> Dict LogStream.Id LogStream.Log
applyFilter model =
    let
        filterer id log =
            if String.length model.filterText > 0 then
                catchDataWhenFiltering model.filterCache id
                    |> Maybe.map (always True)
                    |> Maybe.withDefault False
            else
                True
    in
        LogStream.filter filterer


updateTextFilter : Game.Data -> String -> Model -> Model
updateTextFilter data filter model =
    let
        filterer id log =
            String.contains filter <| toString log.data

        filterCache =
            data
                |> Game.getLogStream
                |> LogStream.filter filterer
                |> Dict.keys
    in
        { model
            | filterText = filter
            , filterCache = filterCache
        }
