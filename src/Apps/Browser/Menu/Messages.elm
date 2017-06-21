module Apps.Browser.Menu.Messages exposing (Msg(..), ActionMsg(..))

import ContextMenu exposing (ContextMenu)
import Apps.Browser.Menu.Models exposing (Menu)


type Msg
    = MenuMsg (ContextMenu.Msg Menu)
    | MenuClick ActionMsg


type ActionMsg
    = DoA
    | DoB
