module Apps.LogViewer.Config exposing (..)

import Game.Servers.Models as Servers
import Game.Servers.Logs.Models as Logs
import Apps.LogViewer.Menu.Config as Menu
import Apps.LogViewer.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , logs : Logs.Model
    , batchMsg : List msg -> msg
    }


menuConfig : Config msg -> Menu.Config msg
menuConfig config =
    { toMsg = MenuMsg >> config.toMsg
    , logs = config.logs
    , batchMsg = config.batchMsg
    }
