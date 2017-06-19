module Utils.Json.Decode exposing (date)

import Date exposing (Date)
import Json.Decode exposing (Decoder, succeed, fail, andThen, string)


date : Decoder Date
date =
    string |> andThen decodeDate



-- internals


decodeDate : String -> Decoder Date
decodeDate str =
    case Date.fromString str of
        Ok date ->
            succeed date

        Err err ->
            fail err
