module Apps.TaskManager.Menu.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import Apps.TaskManager.Menu.Models exposing (Menu)
import Game.Servers.Processes.Models as Processes


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick MenuAction


type MenuAction
    = PauseProcess Processes.ID
    | ResumeProcess Processes.ID
    | RemoveProcess Processes.ID
