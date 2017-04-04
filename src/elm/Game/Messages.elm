module Game.Messages exposing (GameMsg(..))

import Events.Models
import Requests.Models

type GameMsg
    = SetToken (Maybe String)
    | Logout
    | Event Events.Models.Event
    | Request Requests.Models.Request
    | Response Requests.Models.Request Requests.Models.Response
