module Apps.Explorer.Menu.Models exposing (..)

import Game.Servers.Filesystem.Models exposing (Id, Path)
import OS.SessionManager.WindowManager.MenuHandler.Models as MenuHandler


type Menu
    = MenuMainDir Path
    | MenuTreeDir Path
    | MenuMainArchive Id
    | MenuTreeArchive Id
    | MenuExecutable Id
    | MenuActiveAction Id
    | MenuPassiveAction Id


type alias Model =
    MenuHandler.Model Menu


initialMenu : Model
initialMenu =
    MenuHandler.initialModel
