module Landing.Login.Config exposing (..)

import Core.Flags as Core
import Landing.Login.Messages exposing (..)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , onLogin : String -> String -> String -> msg
    }
