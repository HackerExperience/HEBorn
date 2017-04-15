module Game.Software.Events exposing (softwareEventHandler)

import Events.Models exposing (Event(..))
import Game.Software.Models exposing (SoftwareModel)
import Game.Messages exposing (GameMsg)


softwareEventHandler : SoftwareModel -> Event -> ( SoftwareModel, Cmd GameMsg )
softwareEventHandler model event =
    case event of
        _ ->
            ( model, Cmd.none )
