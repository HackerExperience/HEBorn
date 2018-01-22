module OS.SessionManager.WindowManager.Config exposing (..)

import Time exposing (Time)
import Apps.Config as Apps
import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers
import Game.Inventory.Models as Inventory
import Game.BackFlix.Models as BackFlix
import Game.Storyline.Models as Story
import OS.SessionManager.WindowManager.Messages exposing (..)
import OS.SessionManager.WindowManager.Models as WM
import Game.Meta.Types.Context exposing (Context(..))
import OS.SessionManager.Types exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , lastTick : Time
    , story : Story.Model
    , account : Account.Model
    , backFlix : BackFlix.BackFlix
    , servers : Servers.Model
    , activeServer : ( Servers.CId, Servers.Server )
    , activeGateway : ( Servers.CId, Servers.Server )
    , activeContext : Context
    , inventory : Inventory.Model
    , batchMsg : List msg -> msg
    }


appsConfig : Maybe Context -> WM.ID -> WM.TargetContext -> Config msg -> Apps.Config msg
appsConfig maybeContext wId targetContext config =
    { toMsg = AppMsg targetContext wId >> config.toMsg
    , lastTick = config.lastTick
    , account = config.account
    , activeServer =
        Servers.getContextServer
            maybeContext
            config.servers
            (Tuple.second config.activeGateway)
    , inventory = config.inventory
    , story = config.story
    , backFlix = config.backFlix
    , batchMsg = config.batchMsg
    }
