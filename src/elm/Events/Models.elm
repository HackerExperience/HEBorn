module Events.Models
    exposing
        ( Event(..)
        , decodeEvent
        )

import Json.Decode exposing (Decoder, string, decodeString, dict, int, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode
import Requests.Models
    exposing
        ( Response(..)
        , ResponseForEventCool(..)
        , ResponseEventCoolPayload
        )


type Event
    = EventMyCool ResponseForEventCool
    | EventUnknown


type alias TmpData =
    { event : String
    , data : Json.Decode.Value
    }


decoderMyCool : Decoder ResponseEventCoolPayload
decoderMyCool =
    decode ResponseEventCoolPayload
        |> required "foo" string


resultMyCool result =
    case result of
        Ok m ->
            EventMyCool (ResponseEventCoolOk m)

        Err _ ->
            EventMyCool ResponseEventCoolInvalid


getEvent event =
    case event of
        "cool" ->
            EventMyCool ResponseEventCoolInvalid

        _ ->
            EventUnknown


invalidTmpData =
    { event = "invalid"
    , data = Json.Encode.null
    }


decodeEventMeta rawMsg =
    let
        decoder =
            decode TmpData
                |> required "event" string
                |> required "data" Json.Decode.value
    in
        case (decodeValue decoder rawMsg) of
            Ok m ->
                m

            Err _ ->
                invalidTmpData


doit event data =
    case (getEvent event) of
        EventMyCool _ ->
            resultMyCool (decodeValue decoderMyCool data)

        EventUnknown ->
            EventUnknown


decodeEvent msg =
    let
        meta =
            decodeEventMeta msg

        event =
            doit meta.event meta.data
    in
        event
