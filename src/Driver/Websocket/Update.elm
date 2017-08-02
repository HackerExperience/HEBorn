module Driver.Websocket.Update exposing (update)

import Json.Decode exposing (Value, decodeValue, value, string)
import Json.Decode.Pipeline exposing (decode, required)
import Phoenix.Channel as Channel
import Utils.Cmd as CmdUtils
import Core.Dispatch as Dispatch exposing (Dispatch)
import Driver.Websocket.Channels exposing (..)
import Driver.Websocket.Messages exposing (..)
import Driver.Websocket.Models exposing (..)
import Driver.Websocket.Reports exposing (..)
import Events.Events as Events


update : Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update msg model =
    case msg of
        JoinChannel channel topic ->
            if model.defer then
                defer channel topic model
            else
                join channel topic model

        NewEvent channel value ->
            case decodeEvent value of
                Ok { event, data } ->
                    let
                        broadcast =
                            Broadcast <| Events.handler channel event data

                        dispatch =
                            Dispatch.websocket broadcast
                    in
                        ( model, Cmd.none, dispatch )

                Err _ ->
                    ( model, Cmd.none, Dispatch.none )

        Broadcast _ ->
            -- ignore broadcasts
            ( model, Cmd.none, Dispatch.none )



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


defer :
    Channel
    -> Maybe String
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
defer channel topic model =
    -- I think that defer is not going to be used anywhere
    -- it's on the line for removal
    let
        model_ =
            { model | defer = False }

        cmd =
            CmdUtils.delay 0.5 (JoinChannel channel topic)
    in
        ( model_, cmd, Dispatch.none )


join :
    Channel
    -> Maybe String
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
join channel topic model =
    let
        channel_ =
            topic
                |> getAddress channel
                |> Channel.init
                |> Channel.onJoin (reportJoin channel)
                |> Channel.on "event" (NewEvent channel)

        channels =
            channel_ :: model.channels

        model_ =
            { model | channels = channels }
    in
        ( model_, Cmd.none, Dispatch.none )



-- reports


reportJoin : Channel -> a -> Msg
reportJoin channel _ =
    channel
        |> Joined
        |> Events.Report
        |> Broadcast
