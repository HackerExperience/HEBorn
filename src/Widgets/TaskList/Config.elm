module Widgets.TaskList.Config exposing (..)

import Widgets.TaskList.Messages exposing (Msg)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    }
