module Apps.DBAdmin.Messages exposing (Msg(..))

import Game.Servers.Logs.Models exposing (ID)
import Apps.DBAdmin.Models exposing (MainTab(..))


type Msg
    = GoTab MainTab
    | ToogleExpand MainTab ID
    | UpdateTextFilter MainTab String
    | EnterEditing MainTab ID
    | ApplyEditing MainTab ID
    | LeaveEditing MainTab ID
    | StartDeleting MainTab ID
    | EnterSelectingVirus ID
    | UpdateServersEditingNick ID String
    | UpdateServersEditingNotes ID String
    | UpdateServersSelectVirus ID ID
    | DummyNoOp
