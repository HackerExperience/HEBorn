module OS.Header.Models exposing (..)


type OpenMenu
    = NothingOpen
    | GatewayOpen
    | BounceOpen (Maybe String)
    | EndpointOpen
    | ChatOpen
    | ServersOpen
    | AccountOpen
    | NetworkOpen


type alias Model =
    { openMenu : OpenMenu
    , mouseSomewhereInside : Bool
    }


initialModel : Model
initialModel =
    { openMenu = NothingOpen
    , mouseSomewhereInside = False
    }


dropMenu : Model -> Model
dropMenu model =
    { model | openMenu = NothingOpen }
