module Game.Server.Update exposing (..)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(..))
import Game.Server.Messages exposing (ServerMsg(..))
import Game.Server.Models exposing (ServerModel)


update : ServerMsg -> ServerModel -> GameModel -> ( ServerModel, Cmd GameMsg, List CoreMsg )
update msg model game =
    case msg of
        _ ->
            ( model, Cmd.none, [] )
