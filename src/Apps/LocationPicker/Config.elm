module Apps.LocationPicker.Config exposing (..)

import Apps.LocationPicker.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    }
