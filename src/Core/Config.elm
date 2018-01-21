module Core.Config exposing (..)

import Time exposing (Time)
import Core.Flags exposing (Flags)
import Core.Messages exposing (..)
import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Setup.Config as Setup
import Game.Config as Game
import Game.Storyline.Models as Story
import Game.Servers.Shared exposing (CId)
import OS.Config as OS


gameConfig : Game.Config Msg
gameConfig =
    { toMsg = GameMsg
    , batchMsg = MultiMsg
    }


setupConfig : String -> Maybe CId -> Flags -> Setup.Config Msg
setupConfig accountId mainframe flags =
    { toMsg = SetupMsg
    , accountId = accountId
    , mainframe = mainframe
    , flags = flags
    }


osConfig : Account.Model -> Story.Model -> Time -> Servers.Server -> OS.Config Msg
osConfig account story lastTick activeServer =
    { toMsg = OSMsg
    , account = account
    , activeServer = activeServer
    , story = story
    , lastTick = lastTick
    }
