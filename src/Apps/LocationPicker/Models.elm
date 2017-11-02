module Apps.LocationPicker.Models exposing (..)

import Utils.Ports.Map exposing (Coordinates, mapInit)
import Utils.Ports.Geolocation exposing (geoLocReq)
import Apps.LocationPicker.Messages exposing (Msg)
import Apps.LocationPicker.Menu.Models as Menu


type alias Model =
    { menu : Menu.Model
    , self : String
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
    { menu = Menu.initialMenu
    , self = id
    , mapEId = "map-" ++ id
    , coordinates = Nothing
    }


startCmd : Model -> Cmd Msg
startCmd model =
    Cmd.batch
        [ mapInit model.mapEId
        , geoLocReq model.self
        ]


setPos : Maybe Coordinates -> Model -> Model
setPos coordinates model =
    { model | coordinates = coordinates }
