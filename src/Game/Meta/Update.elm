module Game.Meta.Update exposing (..)

import Core.Messages as Core
import Game.Models as Game
import Game.Messages as Game
import Game.Meta.Messages exposing (..)
import Game.Meta.Models exposing (..)


update : Msg -> Model -> Game.Model -> ( Model, Cmd Game.Msg, List Core.Msg )
update msg model game =
    case msg of
        Tick time ->
            ( { model | lastTick = time }, Cmd.none, [] )

        _ ->
            ( model, Cmd.none, [] )
