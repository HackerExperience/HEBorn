module Apps.Reference exposing (Reference)

import Game.Meta.Types.Context exposing (Context(..))


type alias WindowID =
    String


type alias ServerID =
    String


type alias SessionID =
    String


type alias Reference =
    { sessionId : SessionID
    , windowId : WindowID
    , context : Context
    }
