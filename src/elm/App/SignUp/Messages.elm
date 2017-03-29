module App.SignUp.Messages exposing (Msg(..))

import Http
import Events.Models
import Requests.Models

type Msg
    = SubmitForm
    | FormSubmit (Result Http.Error String)
    | SetUsername String
    | ValidateUsername
    | SetPassword String
    | ValidatePassword
    | Event Events.Models.Event
    | Request Requests.Models.Request
    | Response Requests.Models.Request Requests.Models.Response
