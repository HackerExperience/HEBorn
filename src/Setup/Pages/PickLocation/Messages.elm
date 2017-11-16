module Setup.Pages.PickLocation.Messages exposing (..)

import Json.Encode exposing (Value)


type Msg
    = MapClick Value
    | GeoLocResp Value
    | GeoRevResp Value
    | ResetLoc
    | Checked (Maybe String)
