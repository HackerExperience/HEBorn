module Game.Account.Messages exposing (Msg(..), RequestMsg(..))

import Events.Events as Events
import Requests.Types exposing (ResponseType)
import Game.Account.Bounces.Messages as Bounces


type Msg
    = DoLogout
    | BouncesMsg Bounces.Msg
    | Request RequestMsg
    | Event Events.Event


type RequestMsg
    = LogoutRequest ResponseType
