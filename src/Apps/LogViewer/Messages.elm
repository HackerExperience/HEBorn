module Apps.LogViewer.Messages exposing (Msg(..))

import Game.Servers.Logs.Models exposing (ID)


type Msg
    = ToogleExpand ID
    | UpdateTextFilter String
    | EnterEditing ID
    | UpdateEditing ID String
    | ApplyEditing ID
    | LeaveEditing ID
