module Landing.Login.Messages
    exposing
        ( Msg(..)
        , RequestMsg(..)
        )

import Requests.Types exposing (ResponseType)


type Msg
    = SubmitLogin
    | SetUsername String
    | ValidateUsername
    | SetPassword String
    | ValidatePassword
    | Request RequestMsg


type RequestMsg
    = LoginRequestMsg ResponseType
