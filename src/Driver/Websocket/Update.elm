module Driver.Websocket.Update exposing (update)

import Dict exposing (Dict)
import Json.Decode exposing (Value, decodeValue, value, string, field)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Phoenix.Channel as Channel
import Utils.React as React exposing (React)
import Driver.Websocket.Config exposing (..)
import Driver.Websocket.Channels exposing (..)
import Driver.Websocket.Messages exposing (..)
import Driver.Websocket.Models exposing (..)


type alias UpdateResponse msg =
    ( Model msg, React msg )


update : Config msg -> Msg -> Model msg -> UpdateResponse msg
update config msg model =
    case msg of
        Connected token _ ->
            ( model, React.msg <| config.onConnected )

        Disconnected ->
            ( model, React.msg <| config.onDisconnected )

        Joined channel value ->
            onJoined config channel value model

        JoinFailed channel value ->
            onJoinFailed config channel value model

        Left channel value ->
            handleLeave config channel (Just value) model

        HandleJoin channel payload ->
            handleJoin config channel payload model

        HandleLeave channel ->
            handleLeave config channel Nothing model



-- internals


onJoined : Config msg -> Channel -> Value -> Model msg -> UpdateResponse msg
onJoined config channel payload model =
    let
        payload_ =
            payload
                |> decodeJoined
                |> Result.withDefault payload

        react =
            case channel of
                AccountChannel _ ->
                    React.msg <| config.onJoinedAccount payload_

                ServerChannel cid ->
                    React.msg <| config.onJoinedServer cid payload_

                BackFlixChannel ->
                    React.none
    in
        ( model, react )


onJoinFailed : Config msg -> Channel -> Value -> Model msg -> UpdateResponse msg
onJoinFailed config channel payload model =
    case decodeJoinFailed payload of
        Ok payload ->
            let
                react =
                    case channel of
                        ServerChannel cid ->
                            React.msg <| config.onJoinFailedServer cid

                        _ ->
                            React.none
            in
                ( model, react )

        Err err ->
            let
                _ =
                    Debug.log "▶ JoinFailed decode error" err
            in
                ( model, React.none )


handleJoin :
    Config msg
    -> Channel
    -> Maybe Value
    -> Model msg
    -> UpdateResponse msg
handleJoin config channel payload model =
    let
        channelAddress =
            getAddress channel

        eventHandler =
            decodeEvent >> config.onEvent channel

        driverChannel =
            channelAddress
                |> Channel.init
                |> Channel.onJoin (Joined channel >> config.toMsg)
                |> Channel.onJoinError (JoinFailed channel >> config.toMsg)
                |> Channel.onLeave (Left channel >> config.toMsg)
                |> Channel.on "event" eventHandler
                |> Channel.on "event_marote" eventHandler

        driverChannel_ =
            case payload of
                Just payload ->
                    Channel.withPayload payload driverChannel

                Nothing ->
                    driverChannel

        channels =
            Dict.insert channelAddress driverChannel_ model.channels
    in
        ( { model | channels = channels }, React.none )


handleLeave :
    Config msg
    -> Channel
    -> Maybe Value
    -> Model msg
    -> UpdateResponse msg
handleLeave config channel payload model =
    let
        channelAddress =
            getAddress channel

        channels =
            Dict.remove channelAddress model.channels
    in
        ( { model | channels = channels }
        , React.msg <| config.onLeft channel payload
        )



-- helpers


decodeJoined : Value -> Result String Value
decodeJoined =
    decodeValue <| field "data" value


decodeJoinFailed : Value -> Result String Value
decodeJoinFailed =
    decodeValue <| field "data" value


decodeEvent : Value -> Result String ( String, String, Value )
decodeEvent =
    decode (,,)
        |> required "event" string
        |> optional "request_id" string ""
        |> required "data" value
        |> decodeValue
