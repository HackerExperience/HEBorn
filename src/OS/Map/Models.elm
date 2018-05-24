module OS.Map.Models exposing (..)

import Utils.Ports.Leaflet as Leaflet
import Utils.Ports.Geolocation as Geolocation


type alias Model =
    {}


mapId : String
mapId =
    "map-background"


initialModel : Model
initialModel =
    {}


startCmd : Cmd msg
startCmd =
    Cmd.batch
        [ Leaflet.init mapId
        , Geolocation.getCoordinates mapId
        ]
