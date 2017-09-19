module Game.Meta.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import Game.Servers.Messages as Servers
import Game.Servers.Models as Servers
import Game.Meta.Types exposing (..)
import Game.Meta.Messages exposing (..)
import Game.Meta.Models exposing (..)


update : Game.Model -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update game msg model =
    case msg of
        Tick time ->
            let
                model_ =
                    { model | lastTick = time }
            in
                ( model_, Cmd.none, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )
