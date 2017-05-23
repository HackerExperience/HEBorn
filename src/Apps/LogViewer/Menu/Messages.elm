module Apps.LogViewer.Menu.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import Game.Servers.Logs.Models exposing (LogID)
import Apps.Instances.Models exposing (InstanceID)
import Apps.LogViewer.Menu.Models exposing (Menu)


type MenuAction
    = NormalEntryEdit LogID
    | EdittingEntryApply LogID
    | EdittingEntryCancel LogID


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick MenuAction InstanceID
