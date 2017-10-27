module Landing.Login.Update exposing (..)

import Utils.Update as Update
import Landing.Login.Messages exposing (Msg(..))
import Landing.Login.Models exposing (Model)
import Landing.Login.Requests exposing (..)
import Landing.Login.Requests.Login as Login
import Core.Models as Core
import Core.Dispatch as Dispatch exposing (Dispatch)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Core.Model -> Msg -> Model -> UpdateResponse
update core msg model =
    -- TODO: update to standards
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
            onRequest core (receive data) model


onRequest : Core.Model -> Maybe Response -> Model -> UpdateResponse
onRequest core response model =
    case response of
        Just response ->
            updateRequest core response model

        Nothing ->
            Update.fromModel model


updateRequest : Core.Model -> Response -> Model -> UpdateResponse
updateRequest core response model =
    case response of
        LoginResponse (Login.Okay token id) ->
            onLoginOkay core token id model

        LoginResponse Login.Error ->
            onLoginError core model


onLoginOkay : Core.Model -> String -> String -> Model -> UpdateResponse
onLoginOkay core token id model =
    let
        model_ =
            { model | loginFailed = False }

        dispatch =
            Dispatch.boot id model.username token
    in
        ( model_, Cmd.none, dispatch )


onLoginError : Core.Model -> Model -> UpdateResponse
onLoginError core model =
    let
        model_ =
            { model | loginFailed = True }
    in
        Update.fromModel model_
