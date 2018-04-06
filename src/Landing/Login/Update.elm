module Landing.Login.Update exposing (..)

import Utils.React as React exposing (React)
import Landing.Requests.Login as LoginRequest exposing (loginRequest)
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

        LoginRequest data ->
            onLoginRequest config data model


onSubmitLogin : Config msg -> Model -> UpdateResponse msg
onSubmitLogin config model =
    ( model
    , config
        |> loginRequest model.username model.password
        |> Cmd.map (LoginRequest >> config.toMsg)
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


onLoginRequest :
    Config msg
    -> LoginRequest.Data
    -> Model
    -> UpdateResponse msg
onLoginRequest config data model =
    case data of
        Ok ( token, id ) ->
            ( { model | loginFailed = Nothing }
            , React.msg <| config.onLogin id model.username token
            )

        Err error ->
            case error of
                LoginRequest.WrongCreds ->
                    ( { model | loginFailed = Just WrongCreds }, React.none )

                LoginRequest.NetworkError ->
                    ( { model | loginFailed = Just NetworkError }, React.none )

                LoginRequest.UnknownError ->
                    ( { model | loginFailed = Just HangTheDJ }, React.none )
