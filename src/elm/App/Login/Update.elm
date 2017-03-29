module App.Login.Update exposing (..)

import App.Login.Models exposing (Model)
import App.Login.Messages exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of

        SubmitLogin ->
            ( model, Cmd.none )

        Event event ->
            (model, Cmd.none)

        Request _ ->
            (model, Cmd.none)

        Response request data ->
            (model, Cmd.none)
