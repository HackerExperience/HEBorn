module Game.Account.Events exposing (accountEventHandler)

import Events.Models exposing (Event(..))
import Game.Account.Models exposing (AccountModel)
import Game.Messages exposing (GameMsg)


accountEventHandler : AccountModel -> Event -> ( AccountModel, Cmd GameMsg )
accountEventHandler model event =
    case event of
        _ ->
            ( model, Cmd.none )
