module OS.SessionManager.Config exposing (..)

import Time exposing (Time)
import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers
import Game.Storyline.Models as Story
import Game.BackFlix.Models as BackFlix
import Game.Inventory.Models as Inventory
import Game.Meta.Types.Network as Network
import Game.Account.Bounces.Shared as Bounces
import Game.Meta.Types.Context exposing (Context(..))
import Game.Meta.Types.Requester exposing (Requester)
import OS.SessionManager.WindowManager.Config as WindowManager
import OS.SessionManager.Dock.Config as Dock
import Apps.Config as Apps
import OS.SessionManager.Types exposing (..)
import OS.SessionManager.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , lastTick : Time
    , story : Story.Model
    , servers : Servers.Model
    , account : Account.Model
    , activeServer : ( Servers.CId, Servers.Server )
    , activeContext : Context
    , activeGateway : ( Servers.CId, Servers.Server )
    , inventory : Inventory.Model
    , backFlix : BackFlix.BackFlix
    , endpointCId : Maybe Servers.CId
    , onSetBounce : Maybe Bounces.ID -> msg
    , batchMsg : List msg -> msg
    }


wmConfig : Servers.SessionId -> Config msg -> WindowManager.Config msg
wmConfig sessionId config =
    { toMsg = WindowManagerMsg sessionId >> config.toMsg
    , lastTick = config.lastTick
    , story = config.story
    , account = config.account
    , servers = config.servers
    , activeServer = config.activeServer
    , activeGateway = config.activeGateway
    , activeContext = config.activeContext
    , backFlix = config.backFlix
    , inventory = config.inventory
    , batchMsg = config.batchMsg
    }


dockConfig : Servers.SessionId -> Config msg -> Dock.Config msg
dockConfig sessionId config =
    { toMsg = DockMsg >> config.toMsg
    , accountDock = Account.getDock config.account
    , sessionId = sessionId
    , endpointCId = Servers.getEndpointCId <| Tuple.second config.activeServer
    , wmConfig = wmConfig sessionId config
    , batchMsg = config.batchMsg
    }
