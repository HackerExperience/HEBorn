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
    , appFile : String
    , appVer : Float
    , etaTotal : Int
    , etaNow : Int
    , usage : ResourceUsage
    }


type alias Entries =
    List TaskEntry


type alias TaskManager =
    { tasks : Entries
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
        [ (TaskEntry
            "Encrypt Connection"
            "89.32.182.204"
            "CantTouchThis.enc"
            4.3
            20
            5
            (ResourceUsage 1900000000 786000000 0 0)
          )
        ]
        [ 2100000000, 1800000000, 2100000000, 1800000000 ]
        [ 4096000000, 3464846848, 3164846848 ]
        [ 123, 500, 120000, 123000, 1170000, 140, 160 ]
        [ 123, 500, 120000, 123000, 1170000, 140, 160 ]
        (ResourceUsage 2100000000 4096000000 1024000 512000)
