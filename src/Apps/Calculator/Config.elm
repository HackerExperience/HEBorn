module Apps.Calculator.Config exposing (..)

import Apps.Calculator.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    }
