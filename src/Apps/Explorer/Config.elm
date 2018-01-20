module Apps.Explorer.Config exposing (..)

import Game.Servers.Shared exposing (CId)
import Apps.Explorer.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , activeCId : CId
    }
