module Landing.Login.Update exposing (..)

import Landing.Login.Models exposing (Model)
import Landing.Login.Messages exposing (Msg(..))
import Landing.Login.Requests exposing (..)
import Landing.Login.Requests.Login as Login
import Driver.Websocket.Channels exposing (..)
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
                    Login.request
                        model.username
                        model.password
                        core.game.meta.config
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
            response (receive data) model core


response :
    Response
    -> Model
    -> CoreModel
    -> ( Model, Cmd Msg, List CoreMsg )
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
                    [ callAccount (Login token id)
                    , MsgWebsocket
                        (Ws.UpdateSocket token)
                    , MsgWebsocket
                        (Ws.JoinChannel AccountChannel (Just id))
                    , MsgWebsocket
                        (Ws.JoinChannel RequestsChannel Nothing)
                    ]
            in
                ( model_, Cmd.none, msgs )

        LoginResponse Login.ErrorResponse ->
            let
                model_ =
                    { model | loginFailed = True }
            in
                ( model_, Cmd.none, [] )

        _ ->
            ( model, Cmd.none, [] )
