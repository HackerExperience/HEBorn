port module Utils.Ports.Geolocation exposing (..)

import Json.Decode as D exposing (decodeValue, string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as E


type alias InstanceCheck =
    { reqid : String }


port geoReq : String -> Cmd msg


port geoResp : (E.Value -> msg) -> Sub msg


checkInstance : D.Value -> String -> Bool
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
