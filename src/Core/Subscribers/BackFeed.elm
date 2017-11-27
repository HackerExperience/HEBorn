module Core.Subscribers.BackFeed exposing (..)

import Core.Messages as Core
import Game.Messages as Game
import Core.Subscribers.Helpers exposing (..)
import Game.BackFeed.Models as Models
import Game.BackFeed.Messages as BackFeed
import Core.Dispatch.BackFeed as Dispatch exposing (..)


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        Create a ->
            [ backfeed <| BackFeed.HandleCreate a ]
