module Apps.TaskManager.Models exposing (..)

import Dict
import Utils exposing (andThenWithDefault)
import Apps.TaskManager.Menu.Models as Menu
import Game.Servers.Processes.Models as Processes exposing (..)


type alias ResourceUsage =
    { cpu : Float
    , mem : Float
    , down : Float
    , up : Float
    }


type alias Entries =
    List Processes.Process


type alias TaskManager =
    { localTasks : Processes
    , historyCPU : List Float
    , historyMem : List Float
    , historyDown : List Float
    , historyUp : List Float
    , limits : ResourceUsage
    }


type alias Model =
    { app : TaskManager
    , menu : Menu.Model
    }


name : String
name =
    "Task Manager"


title : Model -> String
title model =
    "Task Manager"


icon : String
icon =
    "taskmngr"


initialModel : Model
initialModel =
    { app = initialTaskManager
    , menu = Menu.initialMenu
    }


increaseHistory : a -> List a -> List a
increaseHistory new old =
    new :: (List.take 9 old)


initialTaskManager : TaskManager
initialTaskManager =
    TaskManager
        Processes.initialProcesses
        [ 2100000000, 1800000000, 2100000000, 1800000000 ]
        [ 4096000000, 3464846848, 3164846848 ]
        [ 123, 500, 120000, 123000, 1017000, 140, 160 ]
        [ 123, 500, 120000, 123000, 1017000, 140, 160 ]
        (ResourceUsage 2100000000 4096000000 1024000 512000)


packUsage : Process -> ResourceUsage
packUsage ({ cpuUsage, memusage, downloadUsage, uploadUsage } as entry) =
    ResourceUsage cpuUsage memusage downloadUsage uploadUsage


updateTasks : Processes -> ResourceUsage -> TaskManager -> TaskManager
updateTasks tasks_ limit old =
    let
        ( cpu, mem, down, up ) =
            List.foldr
                (\({ cpuUsage, memusage, downloadUsage, uploadUsage } as entry) ( cpu_, mem_, down_, up_ ) ->
                    ( cpu_ + cpuUsage
                    , mem_ + memusage
                    , down_ + downloadUsage
                    , up_ + uploadUsage
                    )
                )
                ( 0.0, 0.0, 0.0, 0.0 )
                (Dict.values tasks_)

        historyCPU =
            (increaseHistory cpu old.historyCPU)

        historyMem =
            (increaseHistory mem old.historyMem)

        historyDown =
            (increaseHistory down old.historyDown)

        historyUp =
            (increaseHistory up old.historyUp)
    in
        TaskManager
            tasks_
            historyCPU
            historyMem
            historyDown
            historyUp
            limit


doJob : (Processes -> Process -> Processes) -> TaskManager -> ProcessID -> TaskManager
doJob job app pID =
    let
        process =
            getProcessByID pID app.localTasks

        tasks_ =
            andThenWithDefault
                (job app.localTasks)
                app.localTasks
                process
    in
        { app | localTasks = tasks_ }


pauseProcess : TaskManager -> ProcessID -> TaskManager
pauseProcess =
    doJob Processes.pauseProcess


resumeProcess : TaskManager -> ProcessID -> TaskManager
resumeProcess =
    doJob (Processes.resumeProcess 0)


removeProcess : TaskManager -> ProcessID -> TaskManager
removeProcess =
    doJob Processes.removeProcess
