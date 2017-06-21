module Game.Meta.Update exposing (..)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import Game.Messages as Game
import Game.Meta.Messages exposing (..)
import Game.Meta.Models exposing (..)


update : Msg -> Model -> Game.Model -> ( Model, Cmd Game.Msg, Dispatch )
update msg model game =
    case msg of
        Tick time ->
            ( { model | lastTick = time }, Cmd.none, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )
