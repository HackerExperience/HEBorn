module OS.Header.Update exposing (update)

import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Account.Messages as Account
import Game.Models as Game


update : Game.Model -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update game msg model =
    case msg of
        Logout ->
            let
                dispatch =
                    Dispatch.account Account.Logout
            in
                ( model, Cmd.none, dispatch )

        _ ->
            ( model, Cmd.none, Dispatch.none )
