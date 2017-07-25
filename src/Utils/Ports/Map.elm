port module Utils.Ports.Map exposing (..)


port mapInit : ( String, Float, Float, Int ) -> Cmd msg


port mapCenter : ( String, Float, Float, Int ) -> Cmd msg
