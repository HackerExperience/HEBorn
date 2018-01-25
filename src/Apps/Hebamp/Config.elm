module Apps.Hebamp.Config exposing (..)

import Html exposing (Attribute)
import Apps.Hebamp.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , draggable : Attribute msg
    , onCloseApp : msg
    }
