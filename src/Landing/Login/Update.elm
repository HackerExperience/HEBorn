module Landing.Login.Update exposing (..)

import Utils.React as React exposing (React)
import Landing.Login.Requests exposing (..)
import Landing.Login.Requests.Login as Login
import Landing.Login.Config exposing (..)
import Landing.Login.Messages exposing (..)
import Landing.Login.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        SubmitLogin ->
            onSubmitLogin config model

        SetUsername username ->
            onSetUsername config username model

        SetPassword password ->
            onSetPassword config password model

        Request data ->
            onRequest config (receive data) model


onSubmitLogin : Config msg -> Model -> UpdateResponse msg
onSubmitLogin config model =
    ( model
    , config
        |> Login.request model.username model.password
        |> Cmd.map config.toMsg
        |> React.cmd
    )


onSetUsername : Config msg -> String -> Model -> UpdateResponse msg
onSetUsername config username model =
    ( { model | username = username }
    , React.none
    )


onSetPassword : Config msg -> String -> Model -> UpdateResponse msg
onSetPassword config password model =
    ( { model | password = password }
    , React.none
    )


onRequest : Config msg -> Maybe Response -> Model -> UpdateResponse msg
onRequest config response model =
    case response of
        Just response ->
            updateRequest config response model

        Nothing ->
            ( model, React.none )


updateRequest : Config msg -> Response -> Model -> UpdateResponse msg
updateRequest config response model =
    case response of
        LoginResponse (Login.Okay token id) ->
            onLoginOkay config token id model

        LoginResponse Login.Error ->
            onLoginError config model


onLoginOkay : Config msg -> String -> String -> Model -> UpdateResponse msg
onLoginOkay config token id model =
    ( { model | loginFailed = False }
    , React.msg <| config.onLogin id model.username token
    )


onLoginError : Config msg -> Model -> UpdateResponse msg
onLoginError config model =
    ( { model | loginFailed = True }, React.none )
