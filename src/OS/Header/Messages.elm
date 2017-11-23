module OS.Header.Messages exposing (Msg(..))

import Game.Meta.Types.Context exposing (Context)
import Game.Servers.Shared as Servers
import OS.Header.Models exposing (OpenMenu)
import UI.Widgets.CustomSelect as CustomSelect


type Msg
    = Logout
    | ToggleMenus OpenMenu
    | MouseEnterDropdown
    | MouseLeavesDropdown
    | SelectGateway (Maybe Servers.CId)
    | SelectBounce (Maybe String)
    | SelectEndpoint (Maybe Servers.CId)
    | CheckMenus
    | ContextTo Context
    | ToggleCampaign
    | ServerReadAll Servers.CId
    | ChatReadAll
    | AccountReadAll
