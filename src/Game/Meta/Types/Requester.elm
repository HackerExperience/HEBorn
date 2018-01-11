module Game.Meta.Types.Requester exposing (..)

import Game.Meta.Types.Context exposing (Context(..))


type alias Requester =
    { sessionId : String
    , windowId : String
    , context : Context
    , tabId : Int
    }
