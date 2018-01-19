module Game.Account.Database.Config exposing (Config)

import Time exposing (Time)
import Core.Flags as Core
import Game.Account.Models as Account
import Game.Account.Database.Messages exposing (..)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    }
