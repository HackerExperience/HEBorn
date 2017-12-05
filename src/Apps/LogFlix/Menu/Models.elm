module Apps.LogFlix.Menu.Models exposing (..)

import OS.SessionManager.WindowManager.MenuHandler.Models as MenuHandler
import Game.Servers.Logs.Models exposing (ID)


type Menu
    = Dummy


type alias Model =
    MenuHandler.Model Menu


initialMenu : Model
initialMenu =
    MenuHandler.initialModel
