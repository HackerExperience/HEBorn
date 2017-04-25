module Game.Servers.Logs.Update exposing (..)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(..))
import Game.Servers.Logs.Messages exposing (LogMsg(..))
import Game.Servers.Logs.Models exposing (Logs)


update :
    LogMsg
    -> Logs
    -> GameModel
    -> ( Logs, Cmd GameMsg, List CoreMsg )
update msg model game =
    case msg of
        _ ->
            ( model, Cmd.none, [] )
