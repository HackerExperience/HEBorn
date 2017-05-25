module Apps.TaskManager.Messages exposing (Msg(..))

import Events.Models
import Requests.Models
import Game.Servers.Logs.Models as NetModel exposing (LogID)
import Apps.TaskManager.Menu.Messages as Menu


type Msg
    = MenuMsg Menu.Msg
