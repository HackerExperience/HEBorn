module Apps.TaskManager.Menu.Messages exposing (Msg(..), ActionMsg(..))

import ContextMenu exposing (ContextMenu)
import Apps.TaskManager.Menu.Models exposing (Menu)
import Game.Servers.Processes.Types.Shared exposing (ProcessID)


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick ActionMsg


type ActionMsg
    = PauseProcess ProcessID
    | ResumeProcess ProcessID
    | RemoveProcess ProcessID
