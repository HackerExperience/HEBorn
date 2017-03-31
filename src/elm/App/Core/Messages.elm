module App.Core.Messages exposing (Msg(..))

import Events.Models
import Requests.Models

type Msg
    = SetToken String
    | Event Events.Models.Event
    | Request Requests.Models.Request
    | Response Requests.Models.Request Requests.Models.Response
