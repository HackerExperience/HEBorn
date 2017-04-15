module Landing.Messages exposing (LandMsg(..), landBinds)

import Events.Models
import Requests.Models
import Core.Components exposing (Component)
import Landing.SignUp.Messages
import Landing.Login.Messages


type LandMsg
    = MsgSignUp Landing.SignUp.Messages.Msg
    | MsgLogin Landing.Login.Messages.Msg
    | Event Events.Models.Event
    | Request Requests.Models.Request Component
    | Response Requests.Models.Request Requests.Models.Response
    | NoOp


landBinds =
    { login = Landing.Login.Messages.Response
    , signUp = Landing.SignUp.Messages.Response
    }
