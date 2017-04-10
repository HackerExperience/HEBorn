module Apps.Messages exposing (AppMsg(..), appBinds)

import Events.Models
import Requests.Models
import Core.Components exposing (Component)
import Apps.Explorer.Messages
import Apps.Login.Messages
import Apps.SignUp.Messages


type AppMsg
    = MsgExplorer Apps.Explorer.Messages.Msg
    | MsgLogin Apps.Login.Messages.Msg
    | MsgSignUp Apps.SignUp.Messages.Msg
    | Event Events.Models.Event
    | Request Requests.Models.Request Component
    | Response Requests.Models.Request Requests.Models.Response
    | NoOp


appBinds =
    { login = Apps.Login.Messages.Response }
