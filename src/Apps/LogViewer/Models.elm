module Apps.LogViewer.Models exposing (..)

import Dict
import Utils exposing (andThenWithDefault)
import Game.Servers.Models exposing (ServerID, Server(..), getServerByID, localhostServerID)
import Game.Servers.Logs.Models as Logs exposing (..)
import Apps.LogViewer.Menu.Models as Menu
import Date exposing (Date, fromTime)


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


updateFilter : LogViewer -> String -> Logs -> LogViewer
updateFilter app newFilter =
    updateFilterCache { app | filtering = newFilter }


updateFilterCache : LogViewer -> Logs -> LogViewer
updateFilterCache app input =
    { app
        | filterCache =
            List.filterMap getID
                (List.filter
                    (\log ->
                        andThenWithDefault
                            (String.contains app.filtering)
                            False
                            (getRawContent log)
                    )
                    (Dict.values input)
                )
    }
