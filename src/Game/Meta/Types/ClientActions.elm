module Game.Meta.Types.ClientActions exposing (..)


type ClientActions
    = AccessedTaskManager
    | SpottedNastyVirus


toString : ClientAction -> String
toString context =
    case context of
        AccessedTaskManager ->
            "tutorial_accessed_task_manager"

        SpottedNastyVirus ->
            "tutorial_spotted_nasty_virus"
