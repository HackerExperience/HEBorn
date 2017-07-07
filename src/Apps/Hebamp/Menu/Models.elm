module Apps.Hebamp.Menu.Models exposing (..)

import OS.SessionManager.WindowManager.MenuHandler.Models as MenuHandler


type Menu
    = MenuDummy


type alias Model =
    MenuHandler.Model Menu


initialMenu : Model
initialMenu =
    MenuHandler.initialModel
