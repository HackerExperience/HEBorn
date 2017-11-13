module Setup.Pages.Mainframe.Models exposing (..)

import Game.Servers.Settings.Types as Settings exposing (Settings)


type alias Model =
    { hostname : Maybe String
    , okay : Bool
    }


settings : Model -> List Settings
settings =
    .hostname >> Settings.Name


initialModel : Model
initialModel =
    -- REVIEWER PLS
    { hostname = Nothing
    , okay = True
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
