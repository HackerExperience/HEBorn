module Apps.Browser.Menu.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import Apps.Browser.Menu.Models exposing (Menu)


type MenuAction
    = DoA
    | DoB


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick MenuAction
