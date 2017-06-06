module Driver.Websocket.Update exposing (update)

import Utils
import Phoenix.Socket as Socket
import Phoenix.Channel as Channel
import Driver.Websocket.Models exposing (Model)
import Driver.Websocket.Messages exposing (Msg(..))
import Core.Messages exposing (CoreMsg)
import Core.Models exposing (CoreModel)


update : Msg -> Model -> CoreModel -> ( Model, Cmd Msg, List CoreMsg )
update msg model core =
    case msg of
        UpdateSocketParams params ->
            let
                ( token, account_id ) =
                    params

                socket_ =
                    Socket.withParams [ ( "token", token ) ] model.socket
            in
                ( { model | socket = socket_ }, Cmd.none, [] )

        JoinChannel args ->
            let
                ( model_, cmd ) =
                    if model.defer then
                        ( { model | defer = False }
                        , Utils.delay 0.5 <| JoinChannel args
                        )
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
                a =
                    Debug.log "TODO" "Re-add NewNotification"
            in
                ( model, Cmd.none, [] )
