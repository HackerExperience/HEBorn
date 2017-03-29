module Requests.Decoder exposing (decodeRequest)


import Json.Decode exposing (Decoder, decodeString)

import WS.Models exposing (WSMsg, decodeWSMsg)


decodeRequest : Decoder a -> String -> Result String (WSMsg a)
decodeRequest dataDecoder msg =
    decodeString (decodeWSMsg dataDecoder) msg

