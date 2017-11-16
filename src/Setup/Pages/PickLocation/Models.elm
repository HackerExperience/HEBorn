module Setup.Pages.PickLocation.Models exposing (..)

import Utils.Ports.Map exposing (Coordinates)
import Setup.Settings as Settings exposing (Settings)


type alias Model =
    { coordinates : Maybe Coordinates
    , areaLabel : Maybe String
    , okay : Bool
    }


mapId : String
mapId =
    "map-setup"


geoInstance : String
geoInstance =
    "setup"


initialModel : Model
initialModel =
    { coordinates = Nothing
    , areaLabel = Nothing
    , okay = True -- set me to false after backend integration
    }


getCoords : Model -> Maybe Coordinates
getCoords =
    .coordinates


setCoords : Maybe Coordinates -> Model -> Model
setCoords coordinates model =
    { model | coordinates = coordinates, okay = False }


setAreaLabel : Maybe String -> Model -> Model
setAreaLabel areaLabel model =
    case areaLabel of
        Just area ->
            { model | areaLabel = Just area, okay = True }

        Nothing ->
            { model | areaLabel = Nothing, okay = False }


isOkay : Model -> Bool
isOkay =
    .okay


settings : Model -> List Settings
settings model =
    case model.coordinates of
        Just coords ->
            [ Settings.Location coords ]

        Nothing ->
            []
