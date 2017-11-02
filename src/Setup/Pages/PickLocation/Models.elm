module Setup.Pages.PickLocation.Models exposing (..)

import Utils.Ports.Map exposing (Coordinates)


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
    , okay = False
    }


getCoords : Model -> Maybe Coordinates
getCoords =
    .coordinates


setCoords : Maybe Coordinates -> Model -> Model
setCoords coordinates model =
    { model | coordinates = coordinates, okay = False }


setAreaLabel : Maybe String -> Model -> Model
setAreaLabel areaLabel model =
    { model | areaLabel = areaLabel }


setOkay : Model -> Model
setOkay model =
    { model | okay = True }


isOkay : Model -> Bool
isOkay =
    .okay
