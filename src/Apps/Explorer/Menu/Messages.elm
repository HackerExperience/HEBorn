module Apps.Explorer.Menu.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import Game.Servers.Filesystem.Models exposing (FileID)
import Apps.Explorer.Menu.Models exposing (Menu)


type MenuAction
    = Dummy
    | DeleteFile FileID


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick MenuAction
