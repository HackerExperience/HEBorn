module Apps.LogViewer.Menu.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import Apps.LogViewer.Menu.Models exposing (Menu)


type MenuAction
    = DoA
    | DoB


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick MenuAction
