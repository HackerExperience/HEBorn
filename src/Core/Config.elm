module Core.Config exposing (..)

import Core.Flags exposing (Flags)
import Core.Messages exposing (..)
import Setup.Config as Setup
import Game.Config as Game
import Game.Servers.Shared exposing (CId)
import OS.Config as OS


gameConfig : Game.Config Msg
gameConfig =
    { toMsg = GameMsg
    }


setupConfig : String -> Maybe CId -> Flags -> Setup.Config Msg
setupConfig accountId mainframe flags =
    { toMsg = SetupMsg
    , accountId = accountId
    , mainframe = mainframe
    , flags = flags
    }


osConfig : OS.Config Msg
osConfig =
    { toMsg = OSMsg
    }
