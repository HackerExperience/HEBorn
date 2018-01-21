module Apps.Finance.Config exposing (..)

import Game.Account.Finances.Models as Finances
import Apps.Finance.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , finances : Finances.Model
    }
