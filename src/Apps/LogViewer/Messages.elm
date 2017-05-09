module Apps.LogViewer.Messages exposing (Msg(..))

import Events.Models
import Requests.Models
import Apps.Instances.Models exposing (InstanceID)
import Game.Servers.Logs.Models as NetModel exposing (LogID)
import Apps.LogViewer.Context.Messages as Context


type Msg
    = OpenInstance InstanceID
    | CloseInstance InstanceID
    | SwitchContext InstanceID
    | ContextMsg Context.Msg
    | Event Events.Models.Event
    | Request Requests.Models.Request
    | Response Requests.Models.Request Requests.Models.Response
    | ToogleLog InstanceID NetModel.LogID
