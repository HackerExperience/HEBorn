module Apps.Hebamp.Config exposing (..)

import Apps.Hebamp.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , onCloseApp : msg
    }
