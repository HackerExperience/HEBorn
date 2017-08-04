module OS.Header.Models exposing (..)

import OS.Header.Notifications.Models as Notifications


type OpenMenu
    = NothingOpen
    | OpenGateway
    | OpenBounce
    | OpenEndpoint


type TabNotifications
    = TabGame
    | TabAccount


type alias Model =
    { openMenu : OpenMenu
    , mouseSomewhereInside : Bool
    , notifications : Notifications.Model
    , activeNotificationsTab : TabNotifications
    }


initialModel : Model
initialModel =
    { openMenu = NothingOpen
    , mouseSomewhereInside = False
    , notifications = Notifications.initialModel
    , activeNotificationsTab = TabAccount
    }
