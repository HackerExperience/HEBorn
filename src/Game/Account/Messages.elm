module Game.Account.Messages exposing (Msg(..), RequestMsg(..))

import Json.Decode exposing (Value)
import Events.Events as Events
import Requests.Types exposing (ResponseType)
import Game.Account.Bounces.Messages as Bounces


type Msg
    = DoLogout
    | BouncesMsg Bounces.Msg
    | Request RequestMsg
    | Event Events.Event
    | Bootstrap Value -- TODO: remove this Value


type RequestMsg
    = LogoutRequest ResponseType
