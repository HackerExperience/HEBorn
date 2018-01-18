module Driver.Websocket.Update exposing (update)

import Dict exposing (Dict)
import Json.Decode exposing (Value, decodeValue, value, string)
import Json.Decode.Pipeline exposing (decode, required)
import Phoenix.Channel as Channel
import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Websocket as Ws
import Driver.Websocket.Channels exposing (..)
import Driver.Websocket.Messages exposing (..)
import Driver.Websocket.Models exposing (..)
import Events.Events as Events


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Msg -> Model -> UpdateResponse
update msg model =
    case msg of
        Connected token _ ->
            ( model, Cmd.none, Dispatch.websocket <| Ws.Connected token )

        Disconnected ->
            ( model, Cmd.none, Dispatch.websocket Ws.Disconnected )

        Joined channel value ->
            onJoined channel value model

        JoinFailed channel value ->
            onJoinFailed channel value model

        Leaved channel value ->
            handleLeave channel (Just value) model

        Event channel value ->
            onEvent channel value model

        HandleJoin channel payload ->
            handleJoin channel payload model

        HandleLeave channel ->
            handleLeave channel Nothing model



-- internals


onJoined : Channel -> Value -> Model -> UpdateResponse
onJoined channel payload model =
    let
        -- silent fallback because requests
        payload_ =
            payload
                |> decodeJoined
                |> Result.withDefault payload

        dispatch =
            Dispatch.websocket <|
                Ws.Joined channel payload_
    in
        ( model, Cmd.none, dispatch )


onJoinFailed : Channel -> Value -> Model -> UpdateResponse
onJoinFailed channel payload model =
    case decodeJoinFailed payload of
        Ok payload ->
            let
                dispatch =
                    Dispatch.websocket <|
                        Ws.JoinFailed channel payload
            in
                ( model, Cmd.none, dispatch )

        Err err ->
            let
                _ =
                    Debug.log "▶ JoinFailed decode error" err
            in
                Update.fromModel model


onEvent : Channel -> Value -> Model -> UpdateResponse
onEvent channel value model =
    case decodeEvent value of
        Ok { event, data } ->
            let
                dispatch =
                    data
                        |> Events.events channel event
                        |> Maybe.withDefault Dispatch.none
            in
                ( model, Cmd.none, dispatch )

        Err _ ->
            Update.fromModel model


handleJoin : Channel -> Maybe Value -> Model -> UpdateResponse
handleJoin channel payload model =
    let
        channelAddress =
            getAddress channel

        driverChannel =
            channelAddress
                |> Channel.init
                |> Channel.onJoin (Joined channel)
                |> Channel.onJoinError (JoinFailed channel)
                |> Channel.onLeave (Leaved channel)
                |> Channel.on "event" (Event channel)
                |> Channel.on "event_marote" (Event channel)

        driverChannel_ =
            case payload of
                Just payload ->
                    Channel.withPayload payload driverChannel

                Nothing ->
                    driverChannel

        channels =
            Dict.insert channelAddress driverChannel_ model.channels
    in
        Update.fromModel { model | channels = channels }


handleLeave : Channel -> Maybe Value -> Model -> UpdateResponse
handleLeave channel payload model =
    let
        channelAddress =
            getAddress channel

        channels =
            Dict.remove channelAddress model.channels

        model_ =
            { model | channels = channels }

        dispatch =
            Dispatch.websocket <| Ws.Leaved channel payload
    in
        ( model_, Cmd.none, dispatch )



-- helpers


decodeEvent : Value -> Result String EventBase
decodeEvent =
    let
        decoder =
            decode EventBase
                |> required "data" value
                |> required "event" string
    in
        decodeValue decoder


decodeJoined : Value -> Result String Value
decodeJoined =
    let
        decoder =
            decode identity
                |> required "data" value
    in
        decodeValue decoder


decodeJoinFailed : Value -> Result String Value
decodeJoinFailed =
    let
        decoder =
            decode identity
                |> required "data" value
    in
        decodeValue decoder
