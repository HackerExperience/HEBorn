module Core.Config exposing (..)

import Game.Config as Game
import Core.Messages exposing (..)


gameConfig : Game.Config Msg
gameConfig =
    { toMsg = GameMsg
    }
