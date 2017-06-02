module Apps.TaskManager.Menu.Models exposing (..)

import OS.SessionManager.WindowManager.MenuHandler.Models as MenuHandler
import Game.Servers.Processes.Types.Shared exposing (ProcessID)


type Menu
    = MenuRunningProcess ProcessID
    | MenuPausedProcess ProcessID
    | MenuCompleteProcess ProcessID
    | MenuRemoteProcess ProcessID


type alias Model =
    MenuHandler.Model Menu


initialMenu : Model
initialMenu =
    MenuHandler.initialModel
