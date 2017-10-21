module Setup.Pages.SetHostname.Models exposing (..)


type alias Model =
    { hostname : Maybe String
    , okay : Bool
    }


initialModel : Model
initialModel =
    { hostname = Nothing
    , okay = False
    }


isHostnameSet : Model -> Bool
isHostnameSet { hostname } =
    case hostname of
        Just _ ->
            True

        Nothing ->
            False


setHostname : String -> Model -> Model
setHostname str model =
    if str == "" then
        { model | hostname = Nothing, okay = False }
    else
        { model | hostname = Just str, okay = False }


isOkay : Model -> Bool
isOkay =
    .okay


setOkay : Model -> Model
setOkay model =
    { model | okay = True }
