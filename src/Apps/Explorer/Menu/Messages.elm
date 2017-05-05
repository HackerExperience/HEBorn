module Apps.Explorer.Menu.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import Apps.Instances.Models exposing (InstanceID)
import Apps.Explorer.Menu.Models exposing (Menu)


type MenuAction
    = DoA
    | DoB


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick MenuAction InstanceID
