module OS.Header.Messages exposing (Msg(..))

import Game.Meta.Types.Context exposing (Context)
import Game.Meta.Types.Network exposing (NIP)
import OS.Header.Models exposing (OpenMenu)


type Msg
    = SignOut
    | ToggleMenus OpenMenu
    | MouseEnterDropdown
    | MouseLeavesDropdown
    | SelectBounce (Maybe String)
    | DropMenu
    | SelectNIP NIP
    | CheckMenus
    | ContextTo Context
    | ServerReadAll
    | ChatReadAll
    | AccountReadAll
