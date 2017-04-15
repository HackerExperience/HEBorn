module Events.Models
    exposing
        ( Event(..)
        , decodeEvent
        )

import Json.Decode exposing (Decoder, string, int, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode
import Driver.Websocket.Models exposing (WSMsg, invalidWSMsg, getWSMsgMeta)
import Requests.Models
    exposing
        ( Response(..)
        , ResponseForEventCool(..)
        , ResponseEventCoolPayload
        )


type Event
    = EventMyCool ResponseForEventCool
    | EventUnknown


decoderMyCool : Decoder ResponseEventCoolPayload
decoderMyCool =
    decode ResponseEventCoolPayload
        |> required "foo" string


resultMyCool : Result error ResponseEventCoolPayload -> Event
resultMyCool result =
    case result of
        Ok m ->
            EventMyCool (ResponseEventCoolOk m)

        Err _ ->
            EventMyCool ResponseEventCoolInvalid


getEventType : String -> Event
getEventType event =
    case event of
        "cool" ->
            EventMyCool ResponseEventCoolInvalid

        _ ->
            EventUnknown


getEvent : String -> Json.Decode.Value -> Event
getEvent event data =
    case (getEventType event) of
        EventMyCool _ ->
            resultMyCool (decodeValue decoderMyCool data)

        EventUnknown ->
            EventUnknown


decodeEvent : Json.Decode.Value -> Event
decodeEvent msg =
    let
        meta =
            getWSMsgMeta msg

        event =
            getEvent meta.event meta.data
    in
        event
