module Setup.Pages.Mainframe.Models exposing (..)


type alias Model =
    { hostname : Maybe String
    , okay : Bool
    }


initialModel : Model
initialModel =
    { hostname = Nothing
    , okay = False
    }


setMainframeName : String -> Model -> Model
setMainframeName str model =
    if str == "" then
        { model | hostname = Nothing, okay = False }
    else
        { model | hostname = Just str, okay = False }


getHostname : Model -> Maybe String
getHostname =
    .hostname


isOkay : Model -> Bool
isOkay =
    .okay


setOkay : Model -> Model
setOkay model =
    { model | okay = True }
