module Apps.TaskManager.Menu.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import Apps.TaskManager.Menu.Models exposing (Menu)
import Game.Servers.Processes.Types.Shared exposing (ProcessID)


type MenuAction
    = PauseProcess ProcessID
    | ResumeProcess ProcessID
    | RemoveProcess ProcessID


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick MenuAction
