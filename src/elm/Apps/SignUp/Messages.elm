module Apps.SignUp.Messages exposing (Msg(..))

import Events.Models
import Requests.Models

type Msg
    = SubmitForm
    | SetUsername String
    | ValidateUsername
    | SetPassword String
    | ValidatePassword
    | SetEmail String
    | ValidateEmail
    | Event Events.Models.Event
    | Request Requests.Models.Request
    | Response Requests.Models.Request Requests.Models.Response
