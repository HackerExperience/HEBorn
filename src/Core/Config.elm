module Core.Config exposing (..)

import Time exposing (Time)
import Driver.Websocket.Channels exposing (Channel(AccountChannel))
import Driver.Websocket.Messages as Ws
import Game.Config as Game
import Setup.Config as Setup
import OS.Config as OS
import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Servers.Shared exposing (CId)
import Game.Storyline.Models as Story
import Core.Flags exposing (Flags)
import Core.Error as Error exposing (Error)
import Core.Messages exposing (..)


gameConfig : Game.Config Msg
gameConfig =
    { toMsg = GameMsg
    , batchMsg = MultiMsg

    --- account
    , onConnected =
        \accountId ->
            Nothing
                |> Ws.HandleJoin (AccountChannel accountId)
                |> WebsocketMsg
    , onDisconnected = HandleShutdown
    , onError = HandleCrash

    -- account.finances
    , onBALoginSuccess = (\a b -> MultiMsg [])
    , onBALoginFailed = (\a -> MultiMsg [])
    , onBATransferSuccess = (\a -> MultiMsg [])
    , onBATransferFailed = (\a -> MultiMsg [])
    }


setupConfig : String -> Maybe CId -> Flags -> Setup.Config Msg
setupConfig accountId mainframe flags =
    { toMsg = SetupMsg
    , accountId = accountId
    , mainframe = mainframe
    , flags = flags
    }


osConfig :
    Account.Model
    -> Story.Model
    -> Time
    -> Servers.Server
    -> OS.Config Msg
osConfig account story lastTick activeServer =
    { toMsg = OSMsg
    , account = account
    , activeServer = activeServer
    , story = story
    , lastTick = lastTick
    }
