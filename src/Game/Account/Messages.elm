module Game.Account.Messages exposing (AccountMsg(..))

import Requests.Models exposing (ResponseLoginPayload)
import Game.Account.Models exposing (AccountID)


type AccountMsg
    = Login ResponseLoginPayload
    | Logout
