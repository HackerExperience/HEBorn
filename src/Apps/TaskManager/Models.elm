module Apps.TaskManager.Models exposing (..)

import Dict
import Apps.TaskManager.Menu.Models as Menu
import Game.Servers.Models as Servers
import Game.Shared exposing (ID)
import Game.Servers.Processes.Models as Processes


type alias ResourceUsage =
    -- REVIEW: maybe update fields to follow Processes format
    { cpu : Float
    , mem : Float
    , down : Float
    , up : Float
    }


type alias Entries =
    List ( ID, Processes.Process )


type alias Model =
    { menu : Menu.Model
    , limits : ResourceUsage
    , historyCPU : List Float
    , historyMem : List Float
    , historyDown : List Float
    , historyUp : List Float
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
    { menu = Menu.initialMenu
    , limits = (ResourceUsage 1 1 1 1)
    , historyCPU = []
    , historyMem = []
    , historyDown = []
    , historyUp = []
    }


increaseHistory : a -> List a -> List a
increaseHistory new old =
    new :: (List.take 19 old)


packUsage : Processes.ResourcesUsage -> ResourceUsage
packUsage { cpu, mem, down, up } =
    ResourceUsage
        (Processes.getPercentUsage cpu)
        (Processes.getPercentUsage mem)
        (Processes.getPercentUsage down)
        (Processes.getPercentUsage up)


taskUsageSum :
    Processes.ResourcesUsage
    -> ( Float, Float, Float, Float )
    -> ( Float, Float, Float, Float )
taskUsageSum { cpu, mem, down, up } ( cpu_, mem_, down_, up_ ) =
    ( cpu_ + (Tuple.first cpu)
    , mem_ + (Tuple.first mem)
    , down_ + (Tuple.first down)
    , up_ + (Tuple.first up)
    )


onlyLocalTasks : Processes.Model -> List Processes.Process
onlyLocalTasks processes =
    -- TODO: decide a better method for filtering this
    Processes.values processes


updateTasks : Servers.Server -> ResourceUsage -> Model -> Model
updateTasks server limit old =
    let
        tasks =
            Servers.getProcesses server

        reduce process sum =
            process
                |> Processes.getUsage
                |> Maybe.map (flip taskUsageSum sum)
                |> Maybe.withDefault sum

        ( cpu, mem, down, up ) =
            tasks
                |> onlyLocalTasks
                |> List.foldr reduce ( 0.0, 0.0, 0.0, 0.0 )

        historyCPU =
            (increaseHistory cpu old.historyCPU)

        historyMem =
            (increaseHistory mem old.historyMem)

        historyDown =
            (increaseHistory down old.historyDown)

        historyUp =
            (increaseHistory up old.historyUp)
    in
        Model
            old.menu
            limit
            historyCPU
            historyMem
            historyDown
            historyUp
