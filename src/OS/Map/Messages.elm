module OS.Map.Messages exposing (..)

import Utils.Ports.Leaflet as Leaflet
import Utils.Ports.Geolocation as Geolocation


type Msg
    = LeafletMsg Leaflet.Msg
    | GeolocationMsg Geolocation.Msg
