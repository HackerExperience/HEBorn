module Apps.Explorer.Messages exposing (Msg(..))

import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Shared exposing (StorageId)
import Apps.Explorer.Menu.Messages as Menu
import Apps.Explorer.Models exposing (..)


type Msg
    = MenuMsg Menu.Msg
    | GoPath Filesystem.Path
    | GoStorage StorageId
    | UpdateEditing EditingStatus
    | EnterRename Filesystem.Id
    | EnterRenameDir Filesystem.Path
    | ApplyEdit
