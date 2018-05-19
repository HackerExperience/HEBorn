module Apps.LocationPicker.Messages exposing (Msg(..))

import Json.Encode exposing (Value)
import Utils.Ports.Geolocation as Geolocation


type Msg
    = MapClick Value
    | GeolocationMsg Geolocation.Id Geolocation.Msg
