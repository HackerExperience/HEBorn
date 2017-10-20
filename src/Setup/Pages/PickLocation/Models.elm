module Setup.Pages.PickLocation.Models exposing (..)

import Utils.Ports.Map exposing (Coordinates)


type alias Model =
    { coordinates : Maybe Coordinates
    , areaLabel : Maybe String
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
    }


setCoords : Maybe Coordinates -> Model -> Model
setCoords coordinates model =
    { model | coordinates = coordinates }


setAreaLabel : Maybe String -> Model -> Model
setAreaLabel areaLabel model =
    { model | areaLabel = areaLabel }
