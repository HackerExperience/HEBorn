module Apps.Explorer.Messages exposing (..)

import ContextMenu exposing (ContextMenu)
import Events.Models
import Requests.Models
import Apps.Explorer.Context.Models exposing (Context)


type Msg
    = Event Events.Models.Event
    | Request Requests.Models.Request
    | Response Requests.Models.Request Requests.Models.Response
    | ContextMenuMsg (ContextMenu.Msg Context)
    | Item Int
