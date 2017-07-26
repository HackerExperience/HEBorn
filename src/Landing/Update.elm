module Landing.Update exposing (update)

import Core.Models as Core
import Core.Dispatch as Dispatch exposing (Dispatch)
import Landing.Messages exposing (..)
import Landing.Models exposing (Model)
import Landing.SignUp.Update as SignUp
import Landing.Login.Update as Login


update :
    Core.Model
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
update core msg model =
    case msg of
        SignUpMsg msg ->
            let
                ( signUp, cmd, dispatch ) =
                    SignUp.update core msg model.signUp

                model_ =
                    { model | signUp = signUp }

                cmd_ =
                    Cmd.map SignUpMsg cmd
            in
                ( model_, cmd_, dispatch )

        LoginMsg msg ->
            let
                ( login, cmd, dispatch ) =
                    Login.update core msg model.login

                model_ =
                    { model | login = login }

                cmd_ =
                    Cmd.map LoginMsg cmd
            in
                ( model_, cmd_, dispatch )

        _ ->
            ( model, Cmd.none, Dispatch.none )
