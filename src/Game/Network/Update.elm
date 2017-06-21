module Game.Network.Update exposing (..)

import Core.Messages as Core
import Game.Models as Game
import Game.Messages as Game
import Game.Network.Messages exposing (Msg(..))
import Game.Network.Models exposing (Model)


update : Msg -> Model -> Game.Model -> ( Model, Cmd Game.Msg, List Core.Msg )
update msg model game =
    case msg of
        _ ->
            ( model, Cmd.none, [] )
