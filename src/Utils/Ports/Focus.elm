port module Utils.Ports.Focus exposing (..)

import Json.Decode exposing (Value, decodeValue, string)
import Json.Decode.Pipeline exposing (decode, required)


port focusedFetched : (Maybe Value -> msg) -> Sub msg


port fetchFocused : () -> Cmd msg


decodeFocus : Value -> Maybe ( String, String )
decodeFocus v =
    decode (,)
        |> required "id" string
        |> required "type" string
        |> flip decodeValue v
        |> Result.toMaybe


handleFocusDecode :
    (Maybe ( String, String ) -> msg)
    -> Maybe Value
    -> msg
handleFocusDecode msg value =
    value
        |> Maybe.andThen decodeFocus
        |> msg
