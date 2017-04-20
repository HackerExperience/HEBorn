module Game.Servers.Update exposing (..)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(..))
import Game.Servers.Messages exposing (ServerMsg(..))
import Game.Servers.Models exposing (..)
import Game.Servers.Filesystem.Update as Filesystem


update : ServerMsg -> Servers -> GameModel -> ( Servers, Cmd GameMsg, List CoreMsg )
update msg model game =
    case msg of
        MsgFilesystem serverID subMsg ->
            let
                server =
                    getServerByID model serverID

                ( filesystem_, cmd, coreMsg ) =
                    Filesystem.update subMsg (getFilesystem server) game

                server_ =
                    updateFilesystem server filesystem_

                model_ =
                    updateServer model server_
            in
                ( model_, cmd, coreMsg )
