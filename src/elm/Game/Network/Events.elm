module Game.Network.Events exposing (networkEventHandler)

import Events.Models exposing (Event(..))
import Game.Network.Models exposing (NetworkModel)
import Game.Messages exposing (GameMsg)


networkEventHandler : NetworkModel -> Event -> ( NetworkModel, Cmd GameMsg )
networkEventHandler model event =
    case event of
        _ ->
            ( model, Cmd.none )
