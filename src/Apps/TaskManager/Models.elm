module Apps.TaskManager.Models exposing (..)

import Apps.TaskManager.Menu.Models as Menu


type alias TaskManager =
    {}


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
    {}
