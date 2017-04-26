module Game.Servers.Processes.Update exposing (..)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(..))
import Game.Servers.Processes.Messages exposing (ProcessMsg(..))
import Game.Servers.Processes.Models exposing (Processes)


update :
    ProcessMsg
    -> Processes
    -> GameModel
    -> ( Processes, Cmd GameMsg, List CoreMsg )
update msg model game =
    case msg of
        _ ->
            ( model, Cmd.none, [] )
