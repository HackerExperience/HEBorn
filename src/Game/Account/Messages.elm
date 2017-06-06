module Game.Account.Messages
    exposing
        ( AccountMsg(..)
        , RequestMsg(..)
        )

import Requests.Types exposing (ResponseType)


type AccountMsg
    = Login String String
    | Logout
    | Request RequestMsg


type RequestMsg
    = LogoutRequestMsg ResponseType
