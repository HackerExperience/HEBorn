module Requests.Decoder exposing (decodeRequest)

import Json.Decode exposing (Decoder, decodeString)
import WebsocketDriver.Models exposing (WSMsg, decodeWSMsg)


decodeRequest : Decoder a -> String -> Result String a
decodeRequest dataDecoder msg =
    decodeString (dataDecoder) msg
