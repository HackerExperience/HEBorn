module Game.Server.Filesystem.Events exposing (filesystemEventHandler)

import Events.Models exposing (Event(..))
import Game.Server.Filesystem.Models exposing (Filesystem)
import Game.Messages exposing (GameMsg)


filesystemEventHandler : Filesystem -> Event -> ( Filesystem, Cmd GameMsg )
filesystemEventHandler model event =
    case event of
        _ ->
            ( model, Cmd.none )
