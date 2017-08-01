port module Utils.Ports.Map exposing (..)

import Json.Decode as D exposing (decodeValue, float)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as E


type alias Coordinates =
    { lat : Float, lng : Float }


port mapInit : String -> Cmd msg


port mapCenter : ( String, Float, Float, Int ) -> Cmd msg


port mapClick : (E.Value -> msg) -> Sub msg


decodeCoordinates : D.Value -> Result String Coordinates
decodeCoordinates =
    decode Coordinates
        |> required "lat" float
        |> required "lng" float
        |> decodeValue
