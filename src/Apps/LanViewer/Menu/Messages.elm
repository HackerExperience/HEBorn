module Apps.LanViewer.Menu.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import Apps.LanViewer.Menu.Models exposing (Menu)


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick MenuAction


type MenuAction
    = Dummy
