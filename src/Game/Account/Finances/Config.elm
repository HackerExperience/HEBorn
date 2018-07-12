module Game.Account.Finances.Config exposing (Config)

import Core.Flags as Core
import Game.Meta.Types.Desktop.Apps exposing (Requester)
import Game.Account.Models as Account
import Game.Account.Finances.Messages exposing (..)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , accountId : Account.ID
    }
