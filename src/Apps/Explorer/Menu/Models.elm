module Apps.Explorer.Menu.Models exposing (..)

import OS.SessionManager.WindowManager.MenuHandler.Models as MenuHandler


type Menu
    = MenuMainDir
    | MenuTreeDir
    | MenuMainArchive
    | MenuTreeArchive
    | MenuExecutable
    | MenuActiveAction
    | MenuPassiveAction


type alias Model =
    MenuHandler.Model Menu


initialMenu : Model
initialMenu =
    MenuHandler.initialModel
