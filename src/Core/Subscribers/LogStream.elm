module Core.Subscribers.LogStream exposing (..)

import Core.Subscribers.Helpers exposing (..)
import Game.LogStream.Messages as LogStream
import Core.Dispatch.LogStream as Dispatch exposing (..)


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        Create a ->
            [ backfeed <| LogStream.HandleCreate a ]
