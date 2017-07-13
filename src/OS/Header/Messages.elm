module OS.Header.Messages exposing (Msg(..))

import UI.Widgets.CustomSelect as CustomSelect
import Game.Meta.Models exposing (Context)
import OS.Header.Models exposing (OpenMenu(..))


type Msg
    = Logout
    | ToggleMenus OpenMenu
    | CustomSelect CustomSelect.Msg
    | SelectGateway String
    | SelectBounce String
    | SelectEndpoint String
    | CheckMenus
    | ContextTo Context
