module Driver.Websocket.Update exposing (update)

import Utils
import Driver.Websocket.Models exposing (Model, getWSMsgType, getWSMsgMeta, decodeWSMsgMeta, decMe, invalidWSMsg, decodeWSMsg, WSMsgType(..), getResponse)
import Driver.Websocket.Messages exposing (Msg(..))
import Core.Messages exposing (CoreMsg(NoOp, DispatchEvent, HttpReceivedMessage))
import Core.Models exposing (CoreModel)
import Phoenix.Socket as Socket
import Phoenix.Channel as Channel
import Json.Decode exposing (decodeValue)
import Events.Models exposing (..)


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
            if model.defer then
                let
                    cmd =
                        (Utils.delay 0.5 <| JoinChannel args)
                in
                    ( { model | defer = False }, cmd, [] )
            else
                let
                    ( topic, event, msg ) =
                        args

                    channel =
                        Channel.init topic
                            |> Channel.on event (\m -> NewMsg m)
                            |> Channel.withDebug

                    channels_ =
                        model.channels ++ [ channel ]
                in
                    ( { model | channels = channels_ }, Cmd.none, [] )

        NewMsg msg ->
            let
                t =
                    Debug.log "original" (toString msg)

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
                                event =
                                    decodeEvent msg
                            in
                                DispatchEvent event

                        -- WSResponse ->
                        --     let
                        --         request =
                        --             getRequest msg
                        --     in
                        --         DispatchResponse (requestId, body, code)
                        WSInvalid ->
                            NoOp
            in
                ( model, Cmd.none, [ coreMsg ] )

        NewReply msg requestId ->
            let
                ( meta, code ) =
                    getResponse msg

                coreMsg =
                    HttpReceivedMessage ( requestId, code, meta.data )
            in
                ( model, Cmd.none, [ coreMsg ] )
