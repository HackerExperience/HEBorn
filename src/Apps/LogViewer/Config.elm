module Apps.LogViewer.Config exposing (..)

import Game.Servers.Models as Servers
import Game.Servers.Logs.Models as Logs
import Apps.LogViewer.Menu.Config as Menu
import Apps.LogViewer.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , logs : Logs.Model
    }


menuConfig : Config msg -> Menu.Config msg
menuConfig { toMsg, logs } =
    { toMsg = MenuMsg >> toMsg
    , logs = logs
    }
