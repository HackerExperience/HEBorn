module Apps.TaskManager.Models exposing (..)

import Game.Shared exposing (ID)
import Game.Servers.Processes.Models as Processes


type alias Entries =
    List ( ID, Processes.Process )


type alias Model =
    { historyCPU : List Float
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
    { historyCPU = []
    , historyMem = []
    , historyDown = []
    , historyUp = []
    }
