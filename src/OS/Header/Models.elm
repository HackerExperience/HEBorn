module OS.Header.Models exposing (Model, initialModel, OpenMenu(..))


type OpenMenu
    = NothingOpen
    | OpenGateway
    | OpenBounce
    | OpenEndpoint


type alias Model =
    { openMenu : OpenMenu
    , mouseSomewhereInside : Bool
    }


initialModel : Model
initialModel =
    { openMenu = NothingOpen
    , mouseSomewhereInside = False
    }
