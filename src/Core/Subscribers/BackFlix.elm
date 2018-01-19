module Core.Subscribers.BackFlix exposing (..)

import Core.Subscribers.Helpers exposing (..)
import Game.BackFlix.Messages as BackFlix
import Core.Dispatch.BackFlix as Dispatch exposing (..)


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        Create a ->
            [ backflix <| BackFlix.HandleCreate a ]
