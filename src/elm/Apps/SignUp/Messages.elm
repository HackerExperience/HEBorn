module Apps.SignUp.Messages exposing (Msg(..))

import ContextMenu exposing (ContextMenu)
import Events.Models
import Requests.Models
import Apps.SignUp.Context.Models exposing (Context)


type Msg
    = SubmitForm
    | SetUsername String
    | ValidateUsername
    | SetPassword String
    | ValidatePassword
    | SetEmail String
    | ValidateEmail
    | Event Events.Models.Event
    | Request Requests.Models.Request
    | Response Requests.Models.Request Requests.Models.Response
    | ContextMenuMsgS (ContextMenu.Msg Context)
    | ItemS Int
