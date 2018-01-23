module Apps.LocationPicker.Messages exposing (Msg(..))

import Json.Encode exposing (Value)


type Msg
    = MapClick Value
    | GeoResp Value
