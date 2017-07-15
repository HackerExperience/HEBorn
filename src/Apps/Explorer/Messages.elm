module Apps.Explorer.Messages exposing (Msg(..))

import Game.Servers.Filesystem.Shared as Filesystem
import Apps.Explorer.Menu.Messages as Menu
import Apps.Explorer.Models exposing (..)


type Msg
    = MenuMsg Menu.Msg
    | GoPath Filesystem.Location
    | UpdateEditing EditingStatus
    | EnterRename Filesystem.FileID
    | ApplyEdit
