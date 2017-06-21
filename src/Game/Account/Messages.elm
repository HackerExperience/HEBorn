module Game.Account.Messages exposing (Msg(..), RequestMsg(..))

import Events.Events as Events
import Requests.Types exposing (ResponseType)


type Msg
    = Login String String
    | Logout
    | Request RequestMsg
    | Event Events.Response


type RequestMsg
    = LogoutRequest ResponseType
    | ServerIndexRequest ResponseType
