module Game.Network.Update exposing (..)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import Game.Messages as Game
import Game.Network.Messages exposing (Msg(..))
import Game.Network.Models exposing (Model)


update : Msg -> Model -> Game.Model -> ( Model, Cmd Game.Msg, Dispatch )
update msg model game =
    case msg of
        _ ->
            ( model, Cmd.none, Dispatch.none )
