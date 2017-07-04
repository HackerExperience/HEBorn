module OS.Header.Messages exposing (Msg(..))

import Game.Meta.Models exposing (ActiveSession)
import OS.Header.Models exposing (OpenMenu(..))


type Msg
    = Logout
    | ToggleMenus OpenMenu
    | MouseEnterItem
    | MouseLeaveItem
    | SelectGateway Int
    | SelectEndpoint Int
    | SelectBounce Int
    | CheckMenus
    | ContextTo ActiveSession
