module Apps.LogViewer.Config exposing (..)

import Game.Servers.Logs.Models as Logs
import Apps.LogViewer.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , activeCId : String
    , logs : Logs.Model
    }
