module Game.Meta.Update exposing (..)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Messages as Game
import Game.Models as Game
import Game.Meta.Messages exposing (..)
import Game.Meta.Models exposing (..)


update : Game.Model -> Msg -> Model -> ( Model, Cmd Game.Msg, Dispatch )
update game msg model =
    case msg of
        SetGateway id ->
            if List.member id game.account.servers then
                let
                    model_ =
                        { model | gateway = Just id }
                in
                    ( model_, Cmd.none, Dispatch.none )
            else
                ( model, Cmd.none, Dispatch.none )

        Tick time ->
            let
                model_ =
                    { model | lastTick = time }
            in
                ( model_, Cmd.none, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )
