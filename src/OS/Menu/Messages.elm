module OS.Menu.Messages exposing (Msg(..), ActionMsg(..))

import ContextMenu exposing (ContextMenu)
import OS.Menu.Models exposing (Menu)


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick ActionMsg


type ActionMsg
    = NoOp
