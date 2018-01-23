module Apps.TaskManager.Menu.Config exposing (..)

import Game.Servers.Processes.Models as Processes
import Apps.TaskManager.Menu.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , onPauseProcess : Processes.ID -> msg
    , onResumeProcess : Processes.ID -> msg
    , onRemoveProcess : Processes.ID -> msg
    }
