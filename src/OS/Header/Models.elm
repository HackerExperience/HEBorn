module OS.Header.Models exposing (..)


type OpenMenu
    = NothingOpen
    | GatewayOpen
    | BounceOpen
    | EndpointOpen
    | ChatOpen
    | ServersOpen
    | AccountOpen
    | NetworkOpen


type alias Model =
    { openMenu : OpenMenu
    , mouseSomewhereInside : Bool
    , selectedBounce : Maybe String
    }


initialModel : Model
initialModel =
    { openMenu = NothingOpen
    , mouseSomewhereInside = False
    , selectedBounce = Nothing
    }


dropMenu : Model -> Model
dropMenu model =
    { model | openMenu = NothingOpen }
