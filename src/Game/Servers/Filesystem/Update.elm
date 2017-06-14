module Game.Servers.Filesystem.Update exposing (..)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(..))
import Game.Servers.Filesystem.Messages exposing (Msg(..))
import Game.Servers.Filesystem.Models exposing (Filesystem, getFileById, removeFile)


update :
    Msg
    -> Filesystem
    -> GameModel
    -> ( Filesystem, Cmd GameMsg, List CoreMsg )
update msg model game =
    case msg of
        Delete id ->
            let
                file =
                    getFileById model id
            in
                ( removeFile file model, Cmd.none, [] )
