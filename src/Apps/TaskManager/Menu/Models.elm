module Apps.TaskManager.Menu.Models exposing (..)

import OS.SessionManager.WindowManager.MenuHandler.Models as MenuHandler
import Game.Servers.Processes.Models as Processes


type Menu
    = MenuRunningProcess Processes.ID
    | MenuPausedProcess Processes.ID
    | MenuCompleteProcess Processes.ID
    | MenuPartialProcess Processes.ID


type alias Model =
    MenuHandler.Model Menu


initialMenu : Model
initialMenu =
    MenuHandler.initialModel
