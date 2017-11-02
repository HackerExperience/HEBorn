module Apps.LogViewer.Menu.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import Game.Servers.Logs.Models exposing (ID)
import Apps.LogViewer.Menu.Models exposing (Menu)


type MenuAction
    = NormalEntryEdit ID
    | EdittingEntryApply ID
    | EdittingEntryCancel ID
    | EncryptEntry ID
    | DecryptEntry ID
    | HideEntry ID
    | DeleteEntry ID


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick MenuAction
