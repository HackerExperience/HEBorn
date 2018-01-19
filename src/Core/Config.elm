module Core.Config exposing (..)

import Game.Config as Game
import OS.Config as OS
import Core.Messages exposing (..)


gameConfig : Game.Config Msg
gameConfig =
    { toMsg = GameMsg
    }


osConfig : OS.Config Msg
osConfig =
    { toMsg = OSMsg
    }
