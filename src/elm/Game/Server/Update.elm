module Game.Server.Update exposing (..)

import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(..))
import Game.Server.Messages exposing (ServerMsg(..))
import Game.Server.Models exposing (ServerModel)


update : ServerMsg -> ServerModel -> GameModel -> ( ServerModel, Cmd GameMsg, List GameMsg )
update msg model game =
    case msg of
        _ ->
            ( model, Cmd.none, [] )
