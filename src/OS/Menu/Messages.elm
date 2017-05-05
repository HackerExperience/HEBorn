module OS.Menu.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import OS.Menu.Models exposing (Menu)


type MenuAction
    = NoOp


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick MenuAction
