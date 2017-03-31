module App.Core.Update exposing (..)


import App.Core.Models.Core exposing (Model, setToken)
import App.Core.Messages exposing (Msg(..))


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetToken token ->
            let
                account_ = setToken model.account token
            in
                ({model | account = account_}, Cmd.none)

        Logout ->
            let
                account_ = setToken model.account Nothing
            in
                ({model | account = account_}, Cmd.none)

        Event _ ->
            (model, Cmd.none)

        Request _ ->
            (model, Cmd.none)

        Response _ _ ->
            (model, Cmd.none)
