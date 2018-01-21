module Apps.LogViewer.Menu.Config exposing (..)

import Game.Servers.Models as Servers
import Game.Servers.Logs.Models as Logs
import Apps.LogViewer.Menu.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , logs : Logs.Model
    }
