module Apps.LogViewer.Menu.Models exposing (..)

import OS.WindowManager.MenuHandler.Models as MenuHandler


type Menu
    = MenuMain


type alias Model =
    MenuHandler.Model Menu


initialMenu : Model
initialMenu =
    MenuHandler.initialModel
