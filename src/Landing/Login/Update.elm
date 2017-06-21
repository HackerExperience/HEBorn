module Landing.Login.Update exposing (..)

import Landing.Login.Models exposing (Model)
import Landing.Login.Messages exposing (Msg(..))
import Landing.Login.Requests exposing (..)
import Landing.Login.Requests.Login as Login
import Driver.Websocket.Channels exposing (..)
import Core.Messages as Core
import Core.Models as Core
import Core.Dispatcher exposing (callAccount)
import Game.Account.Messages as Account
import Driver.Websocket.Messages as Ws


update : Msg -> Model -> Core.Model -> ( Model, Cmd Msg, List Core.Msg )
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
    -> Core.Model
    -> ( Model, Cmd Msg, List Core.Msg )
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
                    [ callAccount (Account.Login token id)
                    , Core.WebsocketMsg
                        (Ws.UpdateSocket token)
                    , Core.WebsocketMsg
                        (Ws.JoinChannel AccountChannel (Just id))
                    , Core.WebsocketMsg
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
