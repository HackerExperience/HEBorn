module Landing.SignUp.Messages exposing (..)

import Landing.Requests.SignUp as SignUp
import Requests.Types exposing (ResponseType)


type Msg
    = SubmitForm
    | SetUsername String
    | ValidateUsername
    | SetPassword String
    | ValidatePassword
    | SetEmail String
    | ValidateEmail
    | SignUpRequest SignUp.Data
