module Apps.LocationPicker.Models exposing (..)

import Utils.Ports.Map exposing (Coordinates, mapInit)
import Utils.Ports.Geolocation exposing (geoLocReq)
import Apps.LocationPicker.Messages exposing (Msg)
import Apps.LocationPicker.Menu.Models as Menu


type alias LocationPicker =
    { mapEId : String
    , coordinates : Maybe Coordinates
    }


type alias Model =
    { app : LocationPicker
    , menu : Menu.Model
    , self : String
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
    , self = id
    }


initialLocationPicker : String -> LocationPicker
initialLocationPicker id =
    { mapEId = "map-" ++ id
    , coordinates = Nothing
    }


startCmd : Model -> Cmd Msg
startCmd model =
    Cmd.batch
        [ mapInit model.app.mapEId
        , geoLocReq model.self
        ]


setPos : Maybe Coordinates -> Model -> Model
setPos coordinates ({ app } as model) =
    let
        app_ =
            { app | coordinates = coordinates }

        model_ =
            { model | app = app_ }
    in
        model_
