module Setup.Pages.Mainframe.Models exposing (..)

import Game.Servers.Settings.Types as Settings exposing (Settings)


type alias Model =
    { hostname : Maybe String
    , okay : Bool
    }


settings : Model -> List Settings
settings model =
    case model.hostname of
        Just name ->
            [ Settings.Name name ]

        Nothing ->
            []


initialModel : Model
initialModel =
    { hostname = Nothing
    , okay = True -- set me to false after backend integration
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
