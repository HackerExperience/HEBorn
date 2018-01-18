module Game.Account.Config exposing (..)

import Time exposing (Time)
import Core.Flags as Core
import Game.Account.Models exposing (..)
import Game.Account.Finances.Config as Finances
import Game.Account.Messages exposing (..)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    }


financesConfig : ID -> Config msg -> Finances.Config msg
financesConfig accountId config =
    { flags = config.flags
    , toMsg = FinancesMsg >> config.toMsg
    , accountId = accountId
    }
