module Game.Account.Bounces.Config exposing (Config)

import Core.Flags as Core
import Game.Account.Bounces.Messages exposing (..)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    }
