module Driver.Websocket.Update exposing (update)

import Dict exposing (Dict)
import Json.Decode exposing (Value, decodeValue, value, string)
import Json.Decode.Pipeline exposing (decode, required)
import Phoenix.Channel as Channel
import Utils.Cmd as Cmd
import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Driver.Websocket.Channels exposing (..)
import Driver.Websocket.Messages exposing (..)
import Driver.Websocket.Models exposing (..)
import Driver.Websocket.Reports exposing (..)
import Events.Events as Events


update : Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update msg model =
    case msg of
        JoinChannel channel payload ->
            join channel payload model

        LeaveChannel channel ->
            leave channel model

        NewEvent channel value ->
            case decodeEvent value of
                Ok { event, data } ->
                    let
                        dispatch =
                            Events.handler channel event data
                                |> Maybe.map Broadcast
                                |> Maybe.map Dispatch.websocket
                                |> Maybe.withDefault Dispatch.none
                    in
                        ( model, Cmd.none, dispatch )

                Err _ ->
                    Update.fromModel model

        Broadcast _ ->
            -- ignore broadcasts
            Update.fromModel model



-- internals


type alias GenericEvent =
    { data : Value
    , event : String
    }


decodeEvent : Value -> Result String GenericEvent
decodeEvent =
    let
        decoder =
            decode GenericEvent
                |> required "data" value
                |> required "event" string
    in
        decodeValue decoder


join : Channel -> Maybe Value -> Model -> ( Model, Cmd Msg, Dispatch )
join channel payload model =
    let
        channelAddress =
            getAddress channel

        channel_ =
            let
                channel__ =
                    channelAddress
                        |> Channel.init
                        |> Channel.onJoin (reportJoin channel)
                        |> Channel.onJoinError (reportJoinFailed channel)
                        |> Channel.on "event" (NewEvent channel)
            in
                case payload of
                    Just payload ->
                        Channel.withPayload payload channel__

                    Nothing ->
                        channel__

        channels =
            Dict.insert channelAddress channel_ model.channels

        model_ =
            { model | channels = channels }
    in
        Update.fromModel model_


leave : Channel -> Model -> ( Model, Cmd Msg, Dispatch )
leave channel model =
    let
        channelAddress =
            getAddress channel

        channels =
            Dict.remove channelAddress model.channels

        model_ =
            { model | channels = channels }
    in
        Update.fromModel model_



-- reports


reportJoin : Channel -> Value -> Msg
reportJoin channel json =
    Joined channel json
        |> Events.Report
        |> Broadcast


reportJoinFailed : Channel -> Value -> Msg
reportJoinFailed channel json =
    JoinFailed channel json
        |> Events.Report
        |> Broadcast
