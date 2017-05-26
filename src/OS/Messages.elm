module OS.Messages exposing (OSMsg(..))

import Events.Models
import Requests.Models
import OS.SessionManager.Messages as SessionManager
import OS.Menu.Messages as Menu


type OSMsg
    = SessionManagerMsg SessionManager.Msg
    | ContextMenuMsg Menu.Msg
    | Event Events.Models.Event
    | Request Requests.Models.Request
    | Response Requests.Models.Request Requests.Models.Response
