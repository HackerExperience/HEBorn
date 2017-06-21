module Game.Servers.Filesystem.Update exposing (..)

import Core.Messages as Core
import Game.Models as Game
import Game.Messages as Game
import Game.Servers.Filesystem.Messages exposing (Msg(..))
import Game.Servers.Filesystem.Models exposing (Filesystem, getFileById, removeFile)


update :
    Msg
    -> Filesystem
    -> Game.Model
    -> ( Filesystem, Cmd Game.Msg, List Core.Msg )
update msg model game =
    case msg of
        Delete id ->
            let
                file =
                    getFileById model id
            in
                ( removeFile file model, Cmd.none, [] )
