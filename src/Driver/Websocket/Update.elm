module Driver.Websocket.Update exposing (update)

import Utils
import Phoenix.Socket as Socket
import Phoenix.Channel as Channel
import Driver.Websocket.Models exposing (..)
import Driver.Websocket.Messages exposing (..)
import Driver.Websocket.Channels exposing (..)
import Driver.Websocket.Reports exposing (..)
import Events.Events as Events
import Core.Models as Core
import Core.Dispatch as Dispatch exposing (Dispatch)


update : Msg -> Model -> Core.Model -> ( Model, Cmd Msg, Dispatch )
update msg model core =
    case msg of
        UpdateSocket token ->
            let
                socket =
                    Socket.withParams [ ( "token", token ) ] model.socket

                model_ =
                    { model | socket = socket }
            in
                ( model_, Cmd.none, Dispatch.none )

        JoinChannel channel topic ->
            if model.defer then
                defer channel topic model
            else
                join channel topic model

        NewEvent event value ->
            let
                response =
                    Events.handler event value
            in
                ( model, Cmd.none, Dispatch.none )

        Broadcast _ ->
            -- ignore broadcasts
            ( model, Cmd.none, Dispatch.none )



-- internals


defer :
    Channel
    -> Maybe String
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
defer channel topic model =
    let
        model_ =
            { model | defer = False }

        cmd =
            Utils.delay 0.5 (JoinChannel channel topic)
    in
        ( model_, cmd, Dispatch.none )


join :
    Channel
    -> Maybe String
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
join channel topic model =
    let
        events =
            eventsFromChannel channel model

        channel_ =
            topic
                |> getAddress channel
                |> Channel.init
                |> Channel.onJoin (reportJoin channel)
                |> flip (List.foldl reducer) events

        channels =
            channel_ :: model.channels

        model_ =
            { model | channels = channels }
    in
        ( model_, Cmd.none, Dispatch.none )


reducer : ( String, Events.Event ) -> Channel.Channel Msg -> Channel.Channel Msg
reducer ( name, event ) =
    Channel.on name (\value -> NewEvent event value)



-- reports


reportJoin : Channel -> a -> Msg
reportJoin channel _ =
    channel
        |> Joined
        |> Events.Report
        |> Broadcast
