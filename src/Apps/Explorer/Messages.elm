module Apps.Explorer.Messages exposing (Msg(..))

import Game.Servers.Filesystem.Models as Filesystem
import Apps.Explorer.Menu.Messages as Menu
import Apps.Explorer.Models exposing (..)


type Msg
    = MenuMsg Menu.Msg
    | GoPath Filesystem.Path
    | UpdateEditing EditingStatus
    | EnterRename Filesystem.Id
    | EnterRenameDir Filesystem.Path
    | ApplyEdit
