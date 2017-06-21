module Apps.LogViewer.Menu.Messages exposing (Msg(..), ActionMsg(..))

import ContextMenu exposing (ContextMenu)
import Game.Servers.Logs.Models exposing (ID)
import Apps.LogViewer.Menu.Models exposing (Menu)


type ActionMsg
    = NormalEntryEdit ID
    | EdittingEntryApply ID
    | EdittingEntryCancel ID


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick ActionMsg
