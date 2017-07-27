port module Utils.Ports.Map exposing (..)

import Json.Encode exposing (Value)


port mapInit : String -> Cmd msg


port mapCenter : ( String, Float, Float, Int ) -> Cmd msg


port mapClick : (Value -> msg) -> Sub msg
