module Apps.LogViewer.Messages exposing (Msg(..))

import Game.Servers.Logs.Models exposing (ID)
import Apps.LogViewer.Menu.Messages as Menu


type Msg
    = MenuMsg Menu.Msg
    | ToogleExpand ID
    | UpdateTextFilter String
    | EnterEditing ID
    | UpdateEditing ID String
    | ApplyEditing ID
    | LeaveEditing ID
