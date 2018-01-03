module Apps.TaskManager.Models exposing (..)

import Apps.TaskManager.Menu.Models as Menu
import Game.Servers.Models as Servers
import Game.Shared exposing (ID)
import Game.Servers.Processes.Models as Processes


type alias Entries =
    List ( ID, Processes.Process )


type alias Model =
    { menu : Menu.Model
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
    , historyCPU = []
    , historyMem = []
    , historyDown = []
    , historyUp = []
    }


increaseHistory : a -> List a -> List a
increaseHistory new old =
    new :: (List.take 19 old)


taskUsageSum :
    Processes.ResourcesUsage
    -> ( Float, Float, Float, Float )
    -> ( Float, Float, Float, Float )
taskUsageSum { cpu, mem, down, up } ( cpu_, mem_, down_, up_ ) =
    ( cpu_ + (Processes.getPercentUsage cpu)
    , mem_ + (Processes.getPercentUsage mem)
    , down_ + (Processes.getPercentUsage down)
    , up_ + (Processes.getPercentUsage up)
    )


updateTasks : Servers.Server -> Model -> Model
updateTasks server old =
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
                |> Processes.values
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
            historyCPU
            historyMem
            historyDown
            historyUp
