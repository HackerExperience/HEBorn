module OS.Messages exposing (OSMsg(..), call)


import Events.Models
import Requests.Models
import OS.WindowManager.Messages
import OS.Dock.Messages


type OSMsg
    = MsgWM OS.WindowManager.Messages.Msg
    | MsgDock OS.Dock.Messages.Msg
    | Event Events.Models.Event
    | Request Requests.Models.Request
    | Response Requests.Models.Request Requests.Models.Response
    | NoOp


call =
    { wm = MsgWM
    , dock = MsgDock}
