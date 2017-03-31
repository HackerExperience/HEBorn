module App.Core.Update exposing (..)


import App.Core.Models exposing (Model)
import App.Core.Messages exposing (Msg(..))


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetToken token ->
            ({model | token = Just token}, Cmd.none)

        Event _ ->
            (model, Cmd.none)

        Request _ ->
            (model, Cmd.none)

        Response _ _ ->
            (model, Cmd.none)
