module Landing.SignUp.Config exposing (..)

import Core.Flags as Core
import Landing.SignUp.Messages exposing (..)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    }
