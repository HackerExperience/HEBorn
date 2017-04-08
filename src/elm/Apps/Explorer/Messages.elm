module Apps.Explorer.Messages exposing (..)


import Events.Models
import Requests.Models


type Msg
    = Event Events.Models.Event
    | Request Requests.Models.Request
    | Response Requests.Models.Request Requests.Models.Response
