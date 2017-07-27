port module Utils.Ports.Geolocation exposing (..)

import Json.Encode exposing (Value)


port geoReq : String -> Cmd msg


port geoStop : String -> Cmd msg


port geoResp : (Value -> msg) -> Sub msg
