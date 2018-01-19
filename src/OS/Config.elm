module OS.Config exposing (..)

import OS.SessionManager.Config as SessionManager
import OS.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    }
