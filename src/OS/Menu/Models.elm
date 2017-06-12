module OS.Menu.Models exposing (..)

import OS.SessionManager.WindowManager.MenuHandler.Models as MenuHandler


type Menu
    = MenuEmpty


type alias Model =
    MenuHandler.Model Menu


initialContext : Model
initialContext =
    MenuHandler.initialModel
