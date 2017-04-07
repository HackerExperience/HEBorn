module Apps.Login.Messages exposing (..)

import Events.Models
import Requests.Models


type Msg
    = SubmitLogin
    | SetUsername String
    | ValidateUsername
    | SetPassword String
    | ValidatePassword
    | Event Events.Models.Event
    | Request Requests.Models.Request
    | Response Requests.Models.Request Requests.Models.Response
