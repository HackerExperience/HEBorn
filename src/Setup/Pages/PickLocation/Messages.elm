module Setup.Pages.PickLocation.Messages exposing (..)

import Json.Encode exposing (Value)
import Utils.Ports.Leaflet as Leaflet
import Utils.Ports.Geolocation as Geolocation


type Msg
    = ResetLoc
    | Checked (Maybe String)
    | LeafletMsg Leaflet.Id Leaflet.Msg
    | GeolocationMsg Geolocation.Id Geolocation.Msg
