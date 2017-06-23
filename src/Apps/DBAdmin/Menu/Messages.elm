module Apps.DBAdmin.Menu.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import Game.Servers.Logs.Models exposing (ID)
import Apps.DBAdmin.Menu.Models exposing (Menu)


type MenuAction
    = NormalEntryEdit ID
    | EdittingEntryApply ID
    | EdittingEntryCancel ID


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick MenuAction
