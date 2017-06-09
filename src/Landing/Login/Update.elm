module Landing.Login.Update exposing (..)

import Landing.Login.Models exposing (Model)
import Landing.Login.Messages exposing (Msg(..))
import Landing.Login.Requests exposing (..)
import Core.Messages exposing (CoreMsg(MsgWebsocket))
import Core.Models exposing (CoreModel)
import Core.Dispatcher exposing (callAccount)
import Game.Account.Messages exposing (AccountMsg(Login))
import Driver.Websocket.Messages as Ws


update : Msg -> Model -> CoreModel -> ( Model, Cmd Msg, List CoreMsg )
update msg model core =
    case msg of
        SubmitLogin ->
            let
                cmd =
                    login model.username model.password core.game.meta.config
            in
                ( model, cmd, [] )

        SetUsername username ->
            ( { model | username = username }, Cmd.none, [] )

        ValidateUsername ->
            ( model, Cmd.none, [] )

        SetPassword password ->
            ( { model | password = password }, Cmd.none, [] )

        ValidatePassword ->
            ( model, Cmd.none, [] )

        Request data ->
            response (handler data) model core


response :
    Response
    -> Model
    -> CoreModel
    -> ( Model, Cmd Msg, List CoreMsg )
response response model core =
    case response of
        LoginResponse token id ->
            let
                model_ =
                    { model
                        | username = ""
                        , password = ""
                    }

                msgs =
                    [ callAccount (Login token id)
                    , MsgWebsocket
                        (Ws.UpdateSocketParams ( token, id ))
                    , MsgWebsocket
                        (Ws.JoinChannel ( "account:" ++ id, "notification" ))
                    , MsgWebsocket
                        (Ws.JoinChannel ( "requests", "requests" ))
                    ]
            in
                ( model_, Cmd.none, msgs )

        NoOp ->
            ( model, Cmd.none, [] )
