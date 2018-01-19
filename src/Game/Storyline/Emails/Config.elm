module Game.Storyline.Emails.Config exposing (..)

import Core.Flags as Core
import Game.Storyline.Emails.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , accountId : String
    , flags : Core.Flags
    }
