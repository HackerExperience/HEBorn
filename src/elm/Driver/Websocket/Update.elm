module Driver.Websocket.Update exposing (update)

import Utils
import Phoenix.Socket as Socket
import Phoenix.Channel as Channel
import Driver.Websocket.Models
    exposing
        ( Model
        , getWSMsgType
        , getWSMsgMeta
        , WSMsgType(..)
        , getResponse
        )
import Driver.Websocket.Messages exposing (Msg(..))
import Events.Models exposing (decodeEvent)
import Core.Messages exposing (CoreMsg(NoOp, DispatchEvent, NewResponse))
import Core.Models exposing (CoreModel)


update : Msg -> Model -> CoreModel -> ( Model, Cmd Msg, List CoreMsg )
update msg model core =
    case msg of
        UpdateSocketParams params ->
            let
                ( token, account_id ) =
                    params

                socket_ =
                    model.socket
                        |> Socket.withParams [ ( "token", token ) ]
            in
                ( { model | socket = socket_ }, Cmd.none, [] )

        JoinChannel args ->
            let
                ( model_, cmd ) =
                    if model.defer then
                        ( model, Utils.delay 0.5 <| JoinChannel args )
                    else
                        let
                            ( topic, event ) =
                                args

                            channel =
                                Channel.init topic
                                    |> Channel.on event (\m -> NewNotification m)
                                    |> Channel.withDebug

                            channels_ =
                                model.channels ++ [ channel ]
                        in
                            ( { model | channels = channels_ }, Cmd.none )
            in
                ( model_, cmd, [] )

        NewNotification msg ->
            let
                meta =
                    getWSMsgMeta msg

                coreMsg =
                    case (getWSMsgType meta) of
                        WSEvent ->
                            let
                                event =
                                    decodeEvent msg
                            in
                                DispatchEvent event

                        WSResponse ->
                            let
                                d =
                                    Debug.log
                                        "received a reply on an event topic"
                                        (toString msg)
                            in
                                NoOp

                        WSInvalid ->
                            NoOp
            in
                ( model, Cmd.none, [ coreMsg ] )

        NewReply msg requestId ->
            let
                ( meta, code ) =
                    getResponse msg

                coreMsg =
                    NewResponse ( requestId, code, meta.data )
            in
                ( model, Cmd.none, [ coreMsg ] )
