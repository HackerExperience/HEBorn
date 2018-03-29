module Game.Account.Notifications.OnClick exposing (..)

import Game.Account.Notifications.Shared exposing (..)
import Game.Account.Notifications.Config exposing (..)


grabOnClick : ActionConfig msg -> Content -> msg
grabOnClick config content =
    case content of
        Generic _ _ ->
            config.batchMsg []

        NewEmail _ ->
            config.openThunderbird
