module Apps.LocationPicker.Messages exposing (Msg(..))

import Utils.Ports.Leaflet as Leaflet
import Utils.Ports.Geolocation as Geolocation


type Msg
    = LeafletMsg Leaflet.Id Leaflet.Msg
    | GeolocationMsg Geolocation.Id Geolocation.Msg
