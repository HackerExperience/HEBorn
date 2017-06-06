module Apps.Explorer.Menu.Models exposing (..)

import Game.Servers.Filesystem.Models exposing (FileID)
import OS.WindowManager.MenuHandler.Models as MenuHandler


type Menu
    = MenuMainDir FileID
    | MenuTreeDir FileID
    | MenuMainArchive FileID
    | MenuTreeArchive FileID
    | MenuExecutable FileID
    | MenuActiveAction FileID
    | MenuPassiveAction FileID


type alias Model =
    MenuHandler.Model Menu


initialMenu : Model
initialMenu =
    MenuHandler.initialModel
