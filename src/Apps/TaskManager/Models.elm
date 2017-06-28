module Apps.TaskManager.Models exposing (..)

import Dict
import Apps.TaskManager.Menu.Models as Menu
import Game.Servers.Models as Servers
import Game.Servers.Processes.Models as Processes exposing (..)
import Game.Servers.Processes.Types.Local as Local exposing (ProcessProp, ProcessState(..))


type alias ResourceUsage =
    { cpu : Float
    , mem : Float
    , down : Float
    , up : Float
    }


type alias Entries =
    List Processes.Process


type alias TaskManager =
    { limits : ResourceUsage
    , historyCPU : List Float
    , historyMem : List Float
    , historyDown : List Float
    , historyUp : List Float
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
    new :: (List.take 19 old)


initialTaskManager : TaskManager
initialTaskManager =
    TaskManager
        --TODO: Remove DUMMY limits
        (ResourceUsage 2100000000 4096000000 1024000 512000)
        []
        []
        []
        []


packUsage : Local.ProcessProp -> ResourceUsage
packUsage ({ cpuUsage, memUsage, downloadUsage, uploadUsage } as entry) =
    ResourceUsage
        (toFloat cpuUsage)
        (toFloat memUsage)
        (toFloat downloadUsage)
        (toFloat uploadUsage)


taskUsageSum : Local.ProcessProp -> ( Float, Float, Float, Float ) -> ( Float, Float, Float, Float )
taskUsageSum ({ cpuUsage, memUsage, downloadUsage, uploadUsage } as entry) ( cpu_, mem_, down_, up_ ) =
    ( cpu_ + (toFloat cpuUsage)
    , mem_ + (toFloat memUsage)
    , down_ + (toFloat downloadUsage)
    , up_ + (toFloat uploadUsage)
    )


onlyLocalTasks : Processes -> List Local.ProcessProp
onlyLocalTasks =
    Dict.values
        >> List.filterMap
            (\v ->
                case v.prop of
                    LocalProcess p ->
                        Just p

                    _ ->
                        Nothing
            )


updateTasks : Servers.Server -> ResourceUsage -> TaskManager -> TaskManager
updateTasks server limit old =
    let
        tasks =
            Servers.getProcesses server

        ( cpu, mem, down, up ) =
            List.foldr
                taskUsageSum
                ( 0.0, 0.0, 0.0, 0.0 )
                (onlyLocalTasks tasks)

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
            limit
            historyCPU
            historyMem
            historyDown
            historyUp
