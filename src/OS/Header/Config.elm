module OS.Header.Config exposing (..)

import Game.Account.Bounces.Shared as Bounces
import Game.Account.Bounces.Models as Bounces
import Game.Meta.Types.Context exposing (..)
import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Shared exposing (CId)
import Game.Servers.Models as Servers exposing (Server)
import OS.Header.Messages exposing (Msg)


type alias Config msg =
    { toMsg : Msg -> msg
    , onLogout : msg
    , onSetGateway : CId -> msg
    , onSetEndpoint : Maybe CId -> msg
    , onSetContext : Context -> msg
    , onSetBounce : Maybe Bounces.ID -> msg
    , onSetStoryMode : Bool -> msg
    , onReadAllAccountNotifications : msg
    , onReadAllServerNotifications : msg
    , onSetActiveNIP : NIP -> msg
    , bounces : Bounces.Model
    , gateways : List CId
    , endpoints : Maybe (List CId)
    , servers : Servers.Model
    , nips : List NIP
    , activeEndpointCid : Maybe CId
    , activeGateway : ( CId, Server )
    , activeBounce : Maybe Bounces.ID
    , activeContext : Context
    }
