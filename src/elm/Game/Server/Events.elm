module Game.Server.Events exposing (serverEventHandler)


import Events.Models exposing (Event(..))
import Game.Server.Models exposing (ServerModel)
import Game.Messages exposing (GameMsg)


serverEventHandler : ServerModel -> Event -> (ServerModel, Cmd GameMsg)
serverEventHandler model event =
    case event of
        _ ->
            (model, Cmd.none)
