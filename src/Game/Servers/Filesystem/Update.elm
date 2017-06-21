module Game.Servers.Filesystem.Update exposing (..)

import Game.Models as Game
import Game.Messages as Game
import Game.Servers.Filesystem.Messages exposing (Msg(..))
import Game.Servers.Filesystem.Models exposing (Filesystem, getFileById, removeFile)
import Core.Dispatch as Dispatch exposing (Dispatch)


update :
    Msg
    -> Filesystem
    -> Game.Model
    -> ( Filesystem, Cmd Game.Msg, Dispatch )
update msg model game =
    case msg of
        Delete id ->
            let
                file =
                    getFileById model id
            in
                ( removeFile file model, Cmd.none, Dispatch.none )
