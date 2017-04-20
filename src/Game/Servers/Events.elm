module Game.Servers.Events exposing (serversEventHandler)

import Events.Models exposing (Event(..))
import Game.Messages exposing (GameMsg)
import Game.Servers.Models exposing (Servers)


serversEventHandler : Servers -> Event -> ( Servers, Cmd GameMsg )
serversEventHandler model event =
    case event of
        _ ->
            ( model, Cmd.none )
