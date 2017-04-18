module Apps.Explorer.Messages exposing (Msg(..))

import Events.Models
import Requests.Models
import Apps.Instances.Models exposing (InstanceID)
import Apps.Explorer.Context.Messages as Context


type Msg
    = OpenInstance InstanceID
    | CloseInstance InstanceID
    | Event Events.Models.Event
    | Request Requests.Models.Request
    | Response Requests.Models.Request Requests.Models.Response
    | ContextMsg Context.Msg
