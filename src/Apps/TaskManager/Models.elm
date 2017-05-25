module Apps.TaskManager.Models exposing (..)

import Apps.TaskManager.Menu.Models as Menu


type alias ResourceUsage =
    { cpu : Float
    , mem : Float
    , down : Float
    , up : Float
    }


type alias TaskEntry =
    { title : String
    , target : String
    , eta : Int
    , appFile : String
    , appVer : Float
    , usage : ResourceUsage
    }


type alias Entries =
    List TaskEntry


type alias TaskManager =
    { tasks : Entries
    , usage : ResourceUsage
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


initialTaskManager : TaskManager
initialTaskManager =
    TaskManager [] (ResourceUsage 0.0 0.0 0.0 0.0)
