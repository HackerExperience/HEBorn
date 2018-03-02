module OS.WindowManager.Sidebar.Config exposing (..)

import OS.WindowManager.Sidebar.Messages exposing (Msg)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    }
