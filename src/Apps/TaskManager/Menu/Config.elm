module Apps.TaskManager.Menu.Config exposing (..)

import Game.Servers.Shared exposing (CId)
import Apps.TaskManager.Menu.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    }
