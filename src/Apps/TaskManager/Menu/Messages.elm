module Apps.TaskManager.Menu.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import Apps.TaskManager.Menu.Models exposing (Menu)


type MenuAction
    = DoA


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick MenuAction
