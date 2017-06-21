module Apps.Explorer.Menu.Messages exposing (Msg(..), ActionMsg(..))

import ContextMenu exposing (ContextMenu)
import Game.Servers.Filesystem.Models exposing (FileID)
import Apps.Explorer.Menu.Models exposing (Menu)


type ActionMsg
    = Dummy
    | DeleteFile FileID


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick ActionMsg
