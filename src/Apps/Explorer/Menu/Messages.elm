module Apps.Explorer.Menu.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import Apps.Explorer.Menu.Models exposing (Menu)


type MenuAction
    = Dummy


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick MenuAction
