module Game.Servers.Filesystem.Events exposing (filesystemEventHandler)

import Events.Models exposing (Event(..))
import Game.Servers.Filesystem.Models exposing (Filesystem)
import Game.Messages exposing (GameMsg)


filesystemEventHandler : Filesystem -> Event -> ( Filesystem, Cmd GameMsg )
filesystemEventHandler model event =
    case event of
        _ ->
            ( model, Cmd.none )
