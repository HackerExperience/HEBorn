module App.Login.Messages exposing (..)

import Events.Models
import Requests.Models

type Msg
    = SubmitLogin
    | Event Events.Models.Event
    | Request Requests.Models.Request
    | Response Requests.Models.Request Requests.Models.Response
