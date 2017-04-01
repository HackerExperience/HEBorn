module Core.Messages exposing (CoreMsg(..))

import Events.Models
import Requests.Models

type CoreMsg
    = SetToken (Maybe String)
    | Logout
    | Event Events.Models.Event
    | Request Requests.Models.Request
    | Response Requests.Models.Request Requests.Models.Response
