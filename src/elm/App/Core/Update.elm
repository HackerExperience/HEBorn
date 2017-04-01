module App.Core.Update exposing (..)


import App.Core.Models exposing (CoreModel, setToken)
import App.Core.Messages exposing (CoreMsg(..))


update : CoreMsg -> CoreModel -> (CoreModel, Cmd CoreMsg)
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
