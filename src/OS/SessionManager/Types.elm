module OS.SessionManager.Types exposing (..)

import Game.Servers.Shared as Servers
import Game.Meta.Types.Context exposing (Context(..))


type alias ID =
    String


type alias WindowRef =
    -- SM.WindowRef creates a ciclid reference
    ( String, String )


type alias Target =
    { context : Context
    , cid : Servers.CId
    }


targetGateway : Servers.CId -> Target
targetGateway cid =
    { context = Gateway
    , cid = cid
    }


targetEndpoint : Servers.CId -> Target
targetEndpoint cid =
    { context = Endpoint
    , cid = cid
    }
