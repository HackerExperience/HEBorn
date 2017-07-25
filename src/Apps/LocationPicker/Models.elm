module Apps.LocationPicker.Models exposing (..)

import Apps.LocationPicker.Menu.Models as Menu


type alias LocationPicker =
    { mapEId : Maybe String }


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


initialModel : Model
initialModel =
    { app = initialLocationPicker
    , menu = Menu.initialMenu
    }


initialLocationPicker : LocationPicker
initialLocationPicker =
    { mapEId = Nothing }
