module OS.Header.Config exposing (..)

import ContextMenu
import Html exposing (Attribute)
import Game.Account.Bounces.Shared as Bounces
import Game.Account.Bounces.Models as Bounces
import Game.Account.Notifications.Models as AccountNotifications
import Game.Meta.Types.Context exposing (..)
import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Shared exposing (CId)
import Game.Servers.Notifications.Models as ServerNotifications
import OS.Header.Messages exposing (Msg)
import Apps.Params as AppParams exposing (AppParams)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , activeContext : Context
    , activeGatewayCId : CId
    , activeEndpointCId : Maybe CId
    , activeBounce : Maybe Bounces.ID
    , activeNIP : NIP
    , gateways : List CId
    , endpoints : List CId
    , bounces : Bounces.Model
    , nips : List NIP
    , accountNotifications : AccountNotifications.Model
    , serversNotifications : ServerNotifications.Model
    , onOpenApp : AppParams -> CId -> msg
    , onSignOut : msg
    , onSetGateway : CId -> msg
    , onSetEndpoint : Maybe CId -> msg
    , onSetContext : Context -> msg
    , onSetBounce : Maybe Bounces.ID -> msg
    , onReadAllAccountNotifications : msg
    , onReadAllServerNotifications : msg
    , onSetActiveNIP : NIP -> msg
    , getLabel : CId -> Maybe String
    , menuAttr : ContextMenuAttribute msg
    }



-- helpers


type alias ContextMenuItens msg =
    List (List ( ContextMenu.Item, msg ))


type alias ContextMenuAttribute msg =
    ContextMenuItens msg -> Attribute msg
