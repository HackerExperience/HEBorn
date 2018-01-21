module Landing.Update exposing (update)

import Utils.React as React exposing (React)
import Landing.Config exposing (..)
import Landing.Messages exposing (..)
import Landing.Models exposing (Model)
import Landing.SignUp.Update as SignUp
import Landing.Login.Update as Login


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        SignUpMsg msg ->
            let
                ( signUp, react ) =
                    SignUp.update (signupConfig config) msg model.signUp

                model_ =
                    { model | signUp = signUp }
            in
                ( model_, react )

        LoginMsg msg ->
            let
                ( login, react ) =
                    Login.update (loginConfig config) msg model.login

                model_ =
                    { model | login = login }
            in
                ( model_, react )

        _ ->
            ( model, React.none )
