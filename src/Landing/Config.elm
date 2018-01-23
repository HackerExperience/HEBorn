module Landing.Config exposing (..)

import Core.Flags as Core
import Landing.Login.Config as Login
import Landing.SignUp.Config as SignUp
import Landing.Messages exposing (..)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , onLogin : String -> String -> String -> msg
    , windowLoaded : Bool
    }


loginConfig : Config msg -> Login.Config msg
loginConfig config =
    { flags = config.flags
    , toMsg = LoginMsg >> config.toMsg
    , onLogin = config.onLogin
    }


signupConfig : Config msg -> SignUp.Config msg
signupConfig config =
    { flags = config.flags
    , toMsg = SignUpMsg >> config.toMsg
    }
