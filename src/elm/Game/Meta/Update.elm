module Game.Meta.Update exposing (..)


import Utils
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(..))
import Game.Meta.Messages exposing (MetaMsg(..))
import Game.Meta.Models exposing (MetaModel)


update : MetaMsg -> MetaModel -> GameModel -> (MetaModel, Cmd GameMsg, List GameMsg)
update msg model game =
    case msg of

        _ ->
            (model, Cmd.none, [])
