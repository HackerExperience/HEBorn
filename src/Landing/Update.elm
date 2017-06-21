module Landing.Update exposing (update)

import Core.Models as Core
import Landing.Messages exposing (..)
import Landing.Models exposing (Model)
import Landing.SignUp.Update
import Landing.Login.Update
import Core.Dispatch as Dispatch exposing (Dispatch)


update :
    Msg
    -> Model
    -> Core.Model
    -> ( Model, Cmd Msg, Dispatch )
update msg model core =
    case msg of
        SignUpMsg subMsg ->
            let
                ( signUp_, cmd, coreMsg ) =
                    Landing.SignUp.Update.update subMsg model.signUp core
            in
                ( { model | signUp = signUp_ }, Cmd.map SignUpMsg cmd, coreMsg )

        LoginMsg subMsg ->
            let
                ( login_, cmd, coreMsg ) =
                    Landing.Login.Update.update subMsg model.login core
            in
                ( { model | login = login_ }, Cmd.map LoginMsg cmd, coreMsg )

        _ ->
            ( model, Cmd.none, Dispatch.none )
