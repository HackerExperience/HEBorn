module Core.Config exposing (..)

import Core.Flags exposing (Flags)
import Core.Messages exposing (..)
import Setup.Config as Setup
import Game.Config as Game
import Game.Storyline.Models as Story
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


osConfig : Story.Model -> OS.Config Msg
osConfig story =
    { toMsg = OSMsg
    , story = story
    }
