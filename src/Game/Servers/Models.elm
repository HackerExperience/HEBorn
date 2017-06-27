module Game.Servers.Models
    exposing
        ( Model
        , Server
        , ID
        , Type(..)
        , initialModel
        , setFilesystem
        , getFilesystem
        , setLogs
        , getLogs
        , setProcesses
        , getProcesses
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


type Type
    = Local
    | Remote


type alias Server =
    { ip : IP
    , type_ : Type
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
        , type_ = Local
        , filesystem = dummyFS
        , logs = dummyLogs
        , processes = dummyProcesses
        }
        Dict.empty


getFilesystem : Server -> Filesystem
getFilesystem =
    .filesystem


setFilesystem : Filesystem -> Server -> Server
setFilesystem filesystem model =
    { model | filesystem = filesystem }


getLogs : Server -> Logs
getLogs =
    .logs


setLogs : Logs -> Server -> Server
setLogs logs model =
    { model | logs = logs }


getProcesses : Server -> Processes
getProcesses =
    .processes


setProcesses : Processes -> Server -> Server
setProcesses processes model =
    { model | processes = processes }
