module Apps.TaskManager.Menu.Models exposing (..)

import OS.WindowManager.MenuHandler.Models as MenuHandler


type Menu
    = MenuGeneric


type alias Model =
    MenuHandler.Model Menu


initialMenu : Model
initialMenu =
    MenuHandler.initialModel
