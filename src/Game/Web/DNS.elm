module Game.Web.DNS exposing (..)

import Game.Meta.Types exposing (Context(..))
import Game.Web.Types exposing (..)


type alias Requester =
    { sessionId : String
    , windowId : String
    , context : Context
    , tabId : Int
    }
