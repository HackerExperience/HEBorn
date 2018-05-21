module Apps.LocationPicker.Models exposing (..)

import Utils.Ports.Leaflet as Leaflet exposing (Coordinates)
import Utils.Ports.Geolocation exposing (getCoordinates)


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
        [ Leaflet.init model.mapEId
        , getCoordinates model.self
        ]


setPos : Maybe Coordinates -> Model -> Model
setPos coordinates model =
    { model | coordinates = coordinates }
