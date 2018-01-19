module OS.SessionManager.WindowManager.Config exposing (..)

import OS.SessionManager.WindowManager.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    }
