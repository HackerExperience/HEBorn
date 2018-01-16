module Apps.Popup.Menu.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import Apps.Popup.Menu.Models exposing (Menu)


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick MenuAction


type MenuAction
    = Dummy
