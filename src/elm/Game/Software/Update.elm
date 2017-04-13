module Game.Software.Update exposing (..)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(..))
import Game.Software.Messages exposing (SoftwareMsg(..))
import Game.Software.Models exposing (SoftwareModel)


update :
    SoftwareMsg
    -> SoftwareModel
    -> GameModel
    -> ( SoftwareModel, Cmd GameMsg, List CoreMsg )
update msg model game =
    case msg of
        _ ->
            ( model, Cmd.none, [] )
