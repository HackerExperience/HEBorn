module Game.Servers.Filesystem.Update exposing (..)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(..))
import Game.Servers.Filesystem.Messages exposing (FilesystemMsg(..))
import Game.Servers.Filesystem.Models exposing (Filesystem)


update :
    FilesystemMsg
    -> Filesystem
    -> GameModel
    -> ( Filesystem, Cmd GameMsg, List CoreMsg )
update msg model game =
    case msg of
        DeleteFile id ->
            ( model, Cmd.none, [] )
