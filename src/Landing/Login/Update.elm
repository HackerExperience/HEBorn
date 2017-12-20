module Landing.Login.Update exposing (..)

import Utils.Update as Update
import Landing.Login.Messages exposing (Msg(..))
import Landing.Login.Models exposing (Model)
import Landing.Login.Requests exposing (..)
import Landing.Login.Requests.Login as Login
import Core.Models as Core
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Core as Core


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Core.Model -> Msg -> Model -> UpdateResponse
update core msg model =
    case msg of
        SubmitLogin ->
            onSubmitLogin model

        SetUsername username ->
            onSetUsername username model

        ValidateUsername ->
            onValidateUsername model

        SetPassword password ->
            onSetPassword password model

        ValidatePassword ->
            onValidatePassword model

        Request data ->
            onRequest core (receive data) model


onSubmitLogin : Model -> UpdateResponse
onSubmitLogin model =
    let
        cmd =
            Login.request model.username model.password core
    in
        ( model, cmd, Dispatch.none )


onSetUsername : String -> Model -> UpdateResponse
onSetUsername username model =
    let
        model_ =
            { model | username = username }
    in
        Update.fromModel model_


onSetPassword : String -> Model -> UpdateResponse
onSetPassword password model =
    let
        model_ =
            { model | password = password }
    in
        Update.fromModel model_


onValidateUsername : Model -> UpdateResponse
onValidateUsername model =
    Update.fromModel model


onValidatePassword : Model -> UpdateResponse
onValidatePassword model =
    Update.fromModel model


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
            Dispatch.core <| Core.Boot id model.username token
    in
        ( model_, Cmd.none, dispatch )


onLoginError : Core.Model -> Model -> UpdateResponse
onLoginError core model =
    let
        model_ =
            { model | loginFailed = True }
    in
        Update.fromModel model_
