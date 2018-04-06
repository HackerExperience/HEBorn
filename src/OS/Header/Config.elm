module OS.Header.Config exposing (..)

import ContextMenu
import Html exposing (Attribute)
import Game.Account.Bounces.Shared as Bounces
import Game.Account.Bounces.Models as Bounces
import Game.Account.Notifications.Models as AccountNotifications
import Game.Account.Notifications.Config as AccountNotifications
import Game.Meta.Types.Desktop.Apps as DesktopApp exposing (DesktopApp(..))
import Game.Meta.Types.Context exposing (..)
import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Shared exposing (CId)
import Game.Servers.Notifications.Models as ServerNotifications
import Game.Servers.Notifications.Config as ServerNotifications
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
    , onNewApp : DesktopApp -> Maybe Context -> Maybe AppParams -> CId -> msg
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


accountActionConfig : Config msg -> AccountNotifications.ActionConfig msg
accountActionConfig config =
    { batchMsg = config.batchMsg
    , openThunderbird =
        config.onNewApp Email Nothing Nothing config.activeGatewayCId
    }


serverActionConfig : Config msg -> ServerNotifications.ActionConfig msg
serverActionConfig config =
    { batchMsg = config.batchMsg
    , openTaskManager =
        config.onNewApp TaskManager Nothing Nothing config.activeGatewayCId
    , openHackedDatabase =
        config.onNewApp DBAdmin Nothing Nothing config.activeGatewayCId
    , openExplorerInFile =
        -- TODO: Explorer params
        \_ -> config.onNewApp Explorer Nothing Nothing config.activeGatewayCId
    }



-- helpers


type alias ContextMenuItens msg =
    List (List ( ContextMenu.Item, msg ))


type alias ContextMenuAttribute msg =
    ContextMenuItens msg -> Attribute msg
