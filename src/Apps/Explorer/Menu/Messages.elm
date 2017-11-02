module Apps.Explorer.Menu.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import Game.Servers.Filesystem.Models as Filesystem
import Apps.Explorer.Models exposing (EditingStatus)
import Apps.Explorer.Menu.Models exposing (Menu)


type MenuAction
    = Dummy
    | GoPath Filesystem.Path
    | UpdateEditing EditingStatus
    | EnterRename Filesystem.Id
    | EnterRenameDir Filesystem.Path
    | Delete Filesystem.Id
    | DeleteDir Filesystem.Path
    | Run Filesystem.Id
    | Research Filesystem.Id
    | Start Filesystem.Id
    | Stop Filesystem.Id


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick MenuAction
