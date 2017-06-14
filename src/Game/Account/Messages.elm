module Game.Account.Messages
    exposing
        ( AccountMsg(..)
        , RequestMsg(..)
        )

import Events.Events as Events
import Requests.Types exposing (ResponseType)


type AccountMsg
    = Login String String
    | Logout
    | Request RequestMsg
    | Event Events.Response


type RequestMsg
    = LogoutRequestMsg ResponseType
    | ServerIndexRequestMsg ResponseType
