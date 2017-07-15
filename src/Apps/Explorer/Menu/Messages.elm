module Apps.Explorer.Menu.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import Game.Servers.Filesystem.Shared as Filesystem
import Apps.Explorer.Models exposing (EditingStatus)
import Apps.Explorer.Menu.Models exposing (Menu)


type MenuAction
    = Dummy
    | GoPath Filesystem.FileID
    | UpdateEditing EditingStatus
    | EnterRename Filesystem.FileID
    | Delete Filesystem.FileID
    | Run Filesystem.FileID
    | Research Filesystem.FileID
    | Start Filesystem.FileID
    | Stop Filesystem.FileID


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick MenuAction
