module Game.Web.DNS exposing (..)

import Game.Meta.Types exposing (Context(..))
import Game.Web.Types exposing (..)


type Response
    = Okay Site
    | NotFounded Url
    | ConnectionError Url


type alias Requester =
    { sessionId : String
    , windowId : String
    , context : Context
    , tabK : Int
    }
