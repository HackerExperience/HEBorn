module Core.Subscribers.Storyline exposing (dispatch)

import Core.Dispatch.Storyline exposing (..)
import Core.Subscribers.Helpers exposing (..)
import Core.Messages as Core
import Game.Messages as Game
import Game.Storyline.Messages as Storyline


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        _ ->
            []
