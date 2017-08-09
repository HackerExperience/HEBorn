module Setup.Messages exposing (..)

import Json.Encode exposing (Value)
import Setup.Types exposing (..)


type Msg
    = MapClick Value
    | GeoLocResp Value
    | GeoRevResp Value
    | ResetLoc
    | GoStep Step
    | GoOS
