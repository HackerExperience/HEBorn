module Landing.Login.Update exposing (..)

import Landing.Login.Messages exposing (Msg(..))
import Landing.Login.Models exposing (Model)
import Landing.Login.Requests exposing (..)
import Landing.Login.Requests.Login as Login
import Core.Messages as Core
import Core.Models as Core
import Core.Dispatch as Dispatch exposing (Dispatch)


update : Core.Model -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update core msg model =
    case msg of
        SubmitLogin ->
            let
                cmd =
                    Login.request model.username model.password core
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
            response core (receive data) model


response :
    Core.Model
    -> Response
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
response core response model =
    case response of
        LoginResponse (Login.OkResponse token id) ->
            let
                model_ =
                    { model | loginFailed = False }

                dispatch =
                    Dispatch.core (Core.Boot id model.username token True)
            in
                ( model_, Cmd.none, dispatch )

        LoginResponse Login.ErrorResponse ->
            let
                model_ =
                    { model | loginFailed = True }
            in
                ( model_, Cmd.none, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )
