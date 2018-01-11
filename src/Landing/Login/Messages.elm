module Landing.Login.Messages
    exposing
        ( Msg(..)
        , RequestMsg(..)
        )

import Requests.Types exposing (ResponseType)


type Msg
    = SubmitLogin
    | SetUsername String
    | SetPassword String
    | Request RequestMsg


type RequestMsg
    = LoginRequest ResponseType
