port module Utils.Ports.OnLoad exposing (..)

import Json.Encode exposing (Value)


port windowLoaded : (Int -> msg) -> Sub msg
