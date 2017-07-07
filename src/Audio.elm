port module Audio exposing (..)


port setCurrentTime : ( String, Float ) -> Cmd msg


port play : String -> Cmd msg


port pause : String -> Cmd msg
