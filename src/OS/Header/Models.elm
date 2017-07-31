module OS.Header.Models exposing (Model, initialModel, OpenMenu(..))

import OS.Header.Notifications.Models as Notifications


type OpenMenu
    = NothingOpen
    | OpenGateway
    | OpenBounce
    | OpenEndpoint


type alias Model =
    { openMenu : OpenMenu
    , mouseSomewhereInside : Bool
    , notifications : Notifications.Model
    }


initialModel : Model
initialModel =
    { openMenu = NothingOpen
    , mouseSomewhereInside = False
    , notifications = Notifications.initialModel
    }
