module Game.Servers.Filesystem.Update exposing (..)

import Game.Models as Game
import Game.Messages as Game
import Game.Servers.Filesystem.Messages exposing (Msg(..))
import Game.Servers.Filesystem.Models exposing (Filesystem, getFileById, removeFile)
import Core.Dispatch as Dispatch exposing (Dispatch)


update :
    Game.Model
    -> Msg
    -> Filesystem
    -> ( Filesystem, Cmd Game.Msg, Dispatch )
update game msg model =
    case msg of
        Delete id ->
            let
                file =
                    getFileById model id
            in
                ( removeFile file model, Cmd.none, Dispatch.none )
