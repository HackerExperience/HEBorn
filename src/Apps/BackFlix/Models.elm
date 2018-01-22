module Apps.BackFlix.Models exposing (..)

import Dict exposing (Dict)
import Game.BackFlix.Models as BackFlix


type Sorting
    = DefaultSort
    | ByType


type alias Model =
    { filterText : String
    , filterFlags : List Never
    , filterCache : List BackFlix.Id
    , sorting : Sorting
    , selected : MainTab
    }


type MainTab
    = TabAll
    | TabSimple


name : String
name =
    "BackFlix"


title : Model -> String
title model =
    "BackFlix"


icon : String
icon =
    "logfl"


windowInitSize : ( Float, Float )
windowInitSize =
    ( 600, 600 )


initialModel : Model
initialModel =
    { filterText = ""
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


typeToString : BackFlix.Log -> String
typeToString log =
    case log.type_ of
        BackFlix.None ->
            ""

        BackFlix.Request ->
            "Request"

        BackFlix.Join ->
            "Join"

        BackFlix.JoinAccount ->
            "JoinAccount"

        BackFlix.JoinServer ->
            "JoinServer"

        BackFlix.Error ->
            "Error"

        BackFlix.Receive ->
            "Receive"

        BackFlix.Event ->
            "Event"

        BackFlix.Other ->
            "Other"


catchDataWhenFiltering : List BackFlix.Id -> BackFlix.Id -> Maybe BackFlix.Id
catchDataWhenFiltering filterCache log =
    if List.member log filterCache then
        Just log
    else
        Nothing


applyFilter : Model -> BackFlix.BackFlix -> Dict BackFlix.Id BackFlix.Log
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
        BackFlix.filter filterer
