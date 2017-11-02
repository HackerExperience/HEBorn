module Setup.Pages.PickLocation.Messages exposing (..)

import Json.Encode exposing (Value)
import Requests.Types exposing (ResponseType)


type Msg
    = MapClick Value
    | GeoLocResp Value
    | GeoRevResp Value
    | ResetLoc
    | Request RequestMsg


type RequestMsg
    = CheckRequest ResponseType
    | SetRequest ResponseType
