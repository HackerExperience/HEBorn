module OS.Header.Messages exposing (Msg(..))

import UI.Widgets.CustomSelect as CustomSelect
import Game.Meta.Types exposing (Context)
import OS.Header.Models exposing (OpenMenu)
import Game.Network.Types exposing (NIP)


type Msg
    = Logout
    | ToggleMenus OpenMenu
    | MouseEnterDropdown
    | MouseLeavesDropdown
    | SelectGateway (Maybe NIP)
    | SelectBounce (Maybe String)
    | SelectEndpoint (Maybe NIP)
    | CheckMenus
    | ContextTo Context
    | ToggleCampaign
    | ServerReadAll String
    | ChatReadAll
    | AccountReadAll
