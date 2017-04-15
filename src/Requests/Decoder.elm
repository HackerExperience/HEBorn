module Requests.Decoder exposing (decodeRequest)

import Json.Decode exposing (Decoder, decodeValue)
import Driver.Websocket.Models exposing (WSMsg, decodeWSMsg)


decodeRequest : Decoder a -> Json.Decode.Value -> Result String a
decodeRequest dataDecoder msg =
    decodeValue dataDecoder msg
