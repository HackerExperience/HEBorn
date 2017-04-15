module Landing.Login.Update exposing (..)

import Core.Messages exposing (CoreMsg)
import Core.Models exposing (CoreModel)
import Landing.Login.Models exposing (Model)
import Landing.Login.Messages exposing (Msg(..))
import Landing.Login.Requests
    exposing
        ( responseHandler
        , requestLogin
          -- , requestUsernameExists
        )


update : Msg -> Model -> CoreModel -> ( Model, Cmd Msg, List CoreMsg )
update msg model core =
    case msg of
        SubmitLogin ->
            let
                cmd =
                    requestLogin model.username model.password
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

        Event event ->
            ( model, Cmd.none, [] )

        Request _ ->
            ( model, Cmd.none, [] )

        Response request data ->
            responseHandler request data model core
