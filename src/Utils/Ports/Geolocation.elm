port module Utils.Ports.Geolocation exposing (..)

import Json.Decode exposing (Value, decodeValue, at, string)
import Json.Decode.Pipeline exposing (decode, required)


type alias InstanceCheck =
    { reqid : String }


port geoLocReq : String -> Cmd msg


port geoLocResp : (Value -> msg) -> Sub msg


port geoRevReq : ( String, Float, Float ) -> Cmd msg


port geoRevResp : (Value -> msg) -> Sub msg


checkInstance : Value -> String -> Bool
checkInstance v cmp =
    let
        instDecoder =
            decode InstanceCheck
                |> required "reqid" string
                |> decodeValue

        res =
            instDecoder v

        expected =
            (InstanceCheck cmp)
    in
        case res of
            Ok expected ->
                True

            _ ->
                False


decodeLabel : Value -> Result String String
decodeLabel =
    decodeValue (at [ "label" ] string)
