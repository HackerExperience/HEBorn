module OS.Header.Messages exposing (Msg(..))

import UI.Widgets.CustomSelect as CustomSelect
import Game.Meta.Messages exposing (Context)
import OS.Header.Models exposing (OpenMenu(..))


type Msg
    = Logout
    | ToggleMenus OpenMenu
    | CustomSelect CustomSelect.Msg
    | SelectGateway (Maybe String)
    | SelectBounce (Maybe String)
    | SelectEndpoint (Maybe ( String, String ))
    | CheckMenus
    | ContextTo Context
