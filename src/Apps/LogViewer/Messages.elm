module Apps.LogViewer.Messages exposing (Msg(..))

import Events.Models
import Requests.Models
import Game.Servers.Logs.Models as NetModel exposing (LogID)
import Apps.LogViewer.Menu.Messages as Menu


type Msg
    = MenuMsg Menu.Msg
    | ToogleLog NetModel.LogID
    | UpdateFilter String
    | EnterEditing LogID
    | UpdateEditing LogID String
    | ApplyEditing LogID
    | LeaveEditing LogID
