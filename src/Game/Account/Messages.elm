module Game.Account.Messages exposing (Msg(..), RequestMsg(..))

import Json.Decode exposing (Value)
import Events.Events as Events
import Requests.Types exposing (ResponseType)
import Game.Servers.Shared as Servers
import Game.Meta.Types exposing (..)
import Game.Account.Bounces.Messages as Bounces
import Game.Account.Database.Messages as Database
import Game.Notifications.Messages as Notifications


type Msg
    = DoLogout
    | SetGateway Servers.ID
    | SetEndpoint (Maybe Servers.ID)
    | ContextTo Context
    | BouncesMsg Bounces.Msg
    | DatabaseMsg Database.Msg
    | NotificationsMsg Notifications.Msg
    | Request RequestMsg
    | Event Events.Event
    | Bootstrap Value -- TODO: remove this Value


type RequestMsg
    = LogoutRequest ResponseType
