module OS.Header.Config exposing (..)

import Game.Account.Bounces.Shared as Bounces
import Game.Meta.Types.Network exposing (NIP)
import OS.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , onLogout : msg
    , onSetGateway : msg
    , onSetEndpoint : msg
    , onSetContext : msg
    , onSetBounce : Bounces.ID -> msg
    , onSetStoryMode : msg
    , onReadAllAccountNotifications : msg
    , onReadAllServerNotifications : msg
    , onSetActiveNIP : NIP -> msg
    , bounces : Bounces
    , gateways : Servers
    , endpoints : Endpoints
    , nips : List NIP
    , activeContext : Context
    }
