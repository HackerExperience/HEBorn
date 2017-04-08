module Game.Software.Update exposing (..)


import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(..))
import Game.Software.Messages exposing (SoftwareMsg(..))
import Game.Software.Models exposing (SoftwareModel)


update : SoftwareMsg -> SoftwareModel -> GameModel -> (SoftwareModel, Cmd GameMsg, List GameMsg)
update msg model game =
    case msg of

        _ ->
            (model, Cmd.none, [])
