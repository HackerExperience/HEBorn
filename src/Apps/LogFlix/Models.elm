module Apps.LogFlix.Models exposing (..)

import Dict exposing (Dict)
import Game.Data as Game
import Game.Servers.Models as Servers exposing (Server)
import Game.BackFeed.Models as BackFeed
import Apps.LogFlix.Menu.Models as Menu


type Sorting
    = DefaultSort
    | ByType


type alias Model =
    { menu : Menu.Model
    , filterText : String
    , filterFlags : List Never
    , filterCache : List BackFeed.Id
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


typeToString : BackFeed.BackLog -> String
typeToString log =
    case log.type_ of
        BackFeed.None ->
            ""

        BackFeed.Request ->
            "Request"

        BackFeed.Join ->
            "Join"

        BackFeed.JoinAccount ->
            "JoinAccount"

        BackFeed.JoinServer ->
            "JoinServer"

        BackFeed.Error ->
            "Error"

        BackFeed.Receive ->
            "Receive"

        BackFeed.Event ->
            "Event"

        BackFeed.Other ->
            ""


catchDataWhenFiltering : List BackFeed.Id -> BackFeed.Id -> Maybe BackFeed.Id
catchDataWhenFiltering filterCache log =
    if List.member log filterCache then
        Just log
    else
        Nothing


applyFilter : Model -> BackFeed.BackFeed -> Dict BackFeed.Id BackFeed.BackLog
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
        BackFeed.filter filterer


updateTextFilter : Game.Data -> String -> Model -> Model
updateTextFilter data filter model =
    -- TODO
    initialModel



--    let
--        filterer id log =
--            case BackFeed.getContent log of
--                BackFeed.NormalContent data ->
--                    String.contains filter data.raw
--                BackFeed.Encrypted ->
--                    False
--        filterCache =
--            data
--                |> Game.getActiveServer
--                |> Servers.getLogs
--                |> BackFeed.filter filterer
--                |> Dict.keys
--    in
--        { model
--            | filterText = filter
--            , filterCache = filterCache
--        }
