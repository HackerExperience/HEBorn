module Game.Servers.Models
    exposing
        ( Model
        , ID
        , Server
        , initialModel
        , setFilesystem
        , setLogs
        , setProcesses
        )

import Dict exposing (Dict)
import Game.Shared exposing (..)
import Game.Servers.Filesystem.Models exposing (Filesystem, initialFilesystem)
import Game.Servers.Logs.Models as Log exposing (Logs, initialLogs)
import Game.Servers.Processes.Models as Processes exposing (Processes, initialProcesses)


-- DUMMIES

import Game.Servers.Filesystem.Dummy exposing (dummyFS)
import Game.Servers.Logs.Dummy exposing (dummyLogs)
import Game.Servers.Processes.Dummy exposing (dummyProcesses)


type alias ID =
    String


type alias Server =
    { ip : IP
    , filesystem : Filesystem
    , logs : Logs
    , processes : Processes
    }


type alias Model =
    Dict ID Server


initialModel : Model
initialModel =
    Dict.insert "localhost"
        -- DUMMY VALUE FOR PLAYING
        { ip = "localhost"
        , filesystem = dummyFS
        , logs = dummyLogs
        , processes = dummyProcesses
        }
        Dict.empty



-- setFilesystem :
--     filesystem
--     -> { any | filesystem : filesystem }
--     -> { any | filesystem : filesystem }


setFilesystem filesystem model =
    { model | filesystem = filesystem }


setLogs :
    logs
    -> { any | logs : logs }
    -> { any | logs : logs }
setLogs logs model =
    { model | logs = logs }


setProcesses :
    processes
    -> { any | processes : processes }
    -> { any | processes : processes }
setProcesses processes model =
    { model | processes = processes }
