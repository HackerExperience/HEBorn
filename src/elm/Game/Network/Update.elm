module Game.Network.Update exposing (..)

import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(..))
import Game.Network.Messages exposing (NetworkMsg(..))
import Game.Network.Models exposing (NetworkModel)


update : NetworkMsg -> NetworkModel -> GameModel -> ( NetworkModel, Cmd GameMsg, List GameMsg )
update msg model game =
    case msg of
        _ ->
            ( model, Cmd.none, [] )
