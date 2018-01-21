module OS.Header.Messages exposing (Msg(..))

import Game.Meta.Types.Context exposing (Context)
import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Shared as Servers
import OS.Header.Models exposing (OpenMenu)


type Msg
    = Logout
    | ToggleMenus OpenMenu
    | MouseEnterDropdown
    | MouseLeavesDropdown
    | SelectGateway (Maybe Servers.CId)
    | SelectBounce (Maybe String)
    | SelectEndpoint (Maybe Servers.CId)
    | SelectNIP NIP
    | CheckMenus
    | ContextTo Context
    | ToggleCampaign Bool
    | ServerReadAll
    | ChatReadAll
    | AccountReadAll
