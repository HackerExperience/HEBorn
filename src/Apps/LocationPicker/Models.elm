module Apps.LocationPicker.Models exposing (..)

import Utils.Ports.Map exposing (Coordinates, mapInit)
import Utils.Ports.Geolocation exposing (geoLocReq)


type alias Model =
    { self : String
    , mapEId : String
    , coordinates : Maybe Coordinates
    }


name : String
name =
    "LocationPicker"


title : Model -> String
title model =
    "Location Picker"


icon : String
icon =
    "locpk"


initialModel : String -> Model
initialModel id =
    { self = id
    , mapEId = "map-" ++ id
    , coordinates = Nothing
    }


startCmd : Model -> Cmd msg
startCmd model =
    Cmd.batch
        [ mapInit model.mapEId
        , geoLocReq model.self
        ]


setPos : Maybe Coordinates -> Model -> Model
setPos coordinates model =
    { model | coordinates = coordinates }
