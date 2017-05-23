module Apps.LogViewer.Menu.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import Apps.Instances.Models exposing (InstanceID)
import Apps.LogViewer.Menu.Models exposing (Menu)


type MenuAction
    = NormalEntryEdit


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick MenuAction InstanceID
