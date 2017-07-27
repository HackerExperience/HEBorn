module Apps.LocationPicker.Models exposing (..)

import Utils.Ports.Map exposing (mapInit)
import Utils.Ports.Geolocation exposing (geoReq)
import Apps.LocationPicker.Messages exposing (Msg)
import Apps.LocationPicker.Menu.Models as Menu


type alias LatLng =
    { lat : Float, lng : Float }


type alias LocationPicker =
    { mapEId : String
    , pos : Maybe LatLng
    }


type alias Model =
    { app : LocationPicker
    , menu : Menu.Model
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
    { app = initialLocationPicker id
    , menu = Menu.initialMenu
    }


initialLocationPicker : String -> LocationPicker
initialLocationPicker id =
    { mapEId = "map-" ++ id
    , pos = Nothing
    }


startCmd : Model -> Cmd Msg
startCmd model =
    Cmd.batch
        [ mapInit model.app.mapEId
        , geoReq "dummy"
        ]
