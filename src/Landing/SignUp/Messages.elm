module Landing.SignUp.Messages exposing (Msg(..), RequestMsg(..))

import Requests.Types exposing (ResponseType)


type Msg
    = SubmitForm
    | SetUsername String
    | ValidateUsername
    | SetPassword String
    | ValidatePassword
    | SetEmail String
    | ValidateEmail
    | Request RequestMsg


type RequestMsg
    = SignUpRequestMsg ResponseType
