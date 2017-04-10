module Apps.Explorer.Messages exposing (Msg(..))

import Events.Models
import Requests.Models
import Apps.Explorer.Context.Messages as Context


type Msg
    = Event Events.Models.Event
    | Request Requests.Models.Request
    | Response Requests.Models.Request Requests.Models.Response
    | ContextMsg Context.Msg
