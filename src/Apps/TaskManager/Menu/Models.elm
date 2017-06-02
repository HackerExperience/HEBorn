module Apps.TaskManager.Menu.Models exposing (..)

import OS.SessionManager.WindowManager.MenuHandler.Models as MenuHandler
import Game.Servers.Processes.Models exposing (ProcessID)


type Menu
    = MenuRunningProcess ProcessID
    | MenuPausedProcess ProcessID
    | MenuCompleteProcess ProcessID


type alias Model =
    MenuHandler.Model Menu


initialMenu : Model
initialMenu =
    MenuHandler.initialModel
