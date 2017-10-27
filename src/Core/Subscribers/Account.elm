module Core.Subscribers.Account exposing (dispatch)

import Core.Dispatch.Account exposing (..)
import Core.Subscribers.Helpers exposing (..)
import Core.Messages as Core
import Game.Messages as Game
import Game.Account.Messages as Account


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        _ ->
            []
