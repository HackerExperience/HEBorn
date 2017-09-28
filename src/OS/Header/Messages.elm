module OS.Header.Messages exposing (Msg(..))

import UI.Widgets.CustomSelect as CustomSelect
import Game.Meta.Types exposing (Context)
import OS.Header.Models exposing (OpenMenu)


type Msg
    = Logout
    | ToggleMenus OpenMenu
    | MouseEnterDropdown
    | MouseLeavesDropdown
    | SelectGateway (Maybe String)
    | SelectBounce (Maybe String)
    | SelectEndpoint (Maybe String)
    | CheckMenus
    | ContextTo Context
    | ToggleCampaign
    | ServerReadAll String
    | ChatReadAll
    | AccountReadAll
