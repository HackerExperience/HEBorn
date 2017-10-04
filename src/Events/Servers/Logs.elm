module Events.Servers.Logs exposing (Event(..), handler)

import Json.Decode
    exposing
        ( Decoder
        , Value
        , decodeValue
        , list
        , maybe
        , string
        , float
        )
import Json.Decode.Pipeline exposing (required, decode)
import Time exposing (Time)
import Utils.Events exposing (Handler)
import Decoders.Logs


type Event
    = Changed Decoders.Logs.Index


handler : String -> Handler Event
handler event json =
    case event of
        "changed" ->
            onChanged json

        _ ->
            Nothing



-- internals


onChanged : Handler Event
onChanged json =
    case decodeValue Decoders.Logs.index json of
        Ok data ->
            Just <| Changed data

        Err str ->
            Debug.log ("▶ Event parse error " ++ str) Nothing
