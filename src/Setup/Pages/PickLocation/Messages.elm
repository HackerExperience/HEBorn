module Setup.Pages.PickLocation.Messages exposing (..)

import Json.Encode exposing (Value)
import Utils.Ports.Geolocation as Geolocation


type Msg
    = MapClick Value
    | GeolocationMsg Geolocation.Id Geolocation.Msg
    | ResetLoc
    | Checked (Maybe String)
