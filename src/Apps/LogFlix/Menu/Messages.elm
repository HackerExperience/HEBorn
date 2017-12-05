module Apps.LogFlix.Menu.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import Game.Servers.Logs.Models exposing (ID)
import Apps.LogFlix.Menu.Models exposing (Menu)


type MenuAction
    = Dummy


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick MenuAction
