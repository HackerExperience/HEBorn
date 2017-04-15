module Game.Network.Update exposing (..)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(..))
import Game.Network.Messages exposing (NetworkMsg(..))
import Game.Network.Models exposing (NetworkModel)


update : NetworkMsg -> NetworkModel -> GameModel -> ( NetworkModel, Cmd GameMsg, List CoreMsg )
update msg model game =
    case msg of
        _ ->
            ( model, Cmd.none, [] )
