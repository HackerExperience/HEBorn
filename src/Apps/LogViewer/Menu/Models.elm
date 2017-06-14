module Apps.LogViewer.Menu.Models exposing (..)

import OS.SessionManager.WindowManager.MenuHandler.Models as MenuHandler
import Game.Servers.Logs.Models exposing (ID)


type Menu
    = MenuNormalEntry ID
    | MenuEditingEntry ID
    | MenuFilter


type alias Model =
    MenuHandler.Model Menu


initialMenu : Model
initialMenu =
    MenuHandler.initialModel
