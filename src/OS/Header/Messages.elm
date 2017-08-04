module OS.Header.Messages exposing (Msg(..))

import UI.Widgets.CustomSelect as CustomSelect
import Game.Meta.Types exposing (Context)
import OS.Header.Models exposing (OpenMenu, TabNotifications)


type Msg
    = Logout
    | ToggleMenus OpenMenu
    | CustomSelect CustomSelect.Msg
    | SelectGateway (Maybe String)
    | SelectBounce (Maybe String)
    | SelectEndpoint (Maybe ( String, String ))
    | CheckMenus
    | ContextTo Context
    | NotificationsTabGo TabNotifications
