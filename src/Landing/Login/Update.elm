module Landing.Login.Update exposing (..)

import Landing.Login.Models exposing (Model)
import Landing.Login.Messages exposing (Msg(..))
import Landing.Login.Requests exposing (..)
import Landing.Login.Requests.Login as Login
import Driver.Websocket.Channels exposing (..)
import Core.Models as Core
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Account.Messages as Account
import Driver.Websocket.Messages as Ws


update : Msg -> Model -> Core.Model -> ( Model, Cmd Msg, Dispatch )
update msg model core =
    case msg of
        SubmitLogin ->
            let
                cmd =
                    Login.request
                        model.username
                        model.password
                        core.game.meta.config
            in
                ( model, cmd, Dispatch.none )

        SetUsername username ->
            ( { model | username = username }, Cmd.none, Dispatch.none )

        ValidateUsername ->
            ( model, Cmd.none, Dispatch.none )

        SetPassword password ->
            ( { model | password = password }, Cmd.none, Dispatch.none )

        ValidatePassword ->
            ( model, Cmd.none, Dispatch.none )

        Request data ->
            response (receive data) model core


response :
    Response
    -> Model
    -> Core.Model
    -> ( Model, Cmd Msg, Dispatch )
response response model core =
    case response of
        LoginResponse (Login.OkResponse token id) ->
            let
                model_ =
                    { model
                        | username = ""
                        , password = ""
                        , loginFailed = False
                    }

                msgs =
                    Dispatch.batch
                        [ Dispatch.account (Account.Login token id)
                        , Dispatch.websocket
                            (Ws.UpdateSocket token)
                        , Dispatch.websocket
                            (Ws.JoinChannel AccountChannel (Just id))
                        , Dispatch.websocket
                            (Ws.JoinChannel RequestsChannel Nothing)
                        ]
            in
                ( model_, Cmd.none, msgs )

        LoginResponse Login.ErrorResponse ->
            let
                model_ =
                    { model | loginFailed = True }
            in
                ( model_, Cmd.none, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )
