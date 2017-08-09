port module Utils.Ports.OnLoad exposing (..)


port windowLoaded : (Int -> msg) -> Sub msg
