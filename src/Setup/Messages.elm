module Setup.Messages exposing (..)

import Events.Events as Events
import Json.Encode exposing (Value)


type Msg
    = MapClick Value
    | GeoResp Value
    | Event Events.Response
