module Apps.TaskManager.Config exposing (..)

import Time exposing (Time)
import Game.Servers.Shared exposing (CId)
import Game.Servers.Processes.Models as Processes
import Apps.TaskManager.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , activeCId : CId
    , processes : Processes.Model
    , lastTick : Time
    }
