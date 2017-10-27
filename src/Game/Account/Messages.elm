module Game.Account.Messages exposing (Msg(..), RequestMsg(..))

import Json.Decode exposing (Value)
import Requests.Types exposing (ResponseType)
import Game.Servers.Shared as Servers
import Game.Meta.Types exposing (..)
import Game.Account.Bounces.Messages as Bounces
import Game.Account.Database.Messages as Database
import Game.Notifications.Messages as Notifications


type Msg
    = DoLogout
    | DoCrash String String
    | SetGateway Servers.CId
    | SetEndpoint (Maybe Servers.CId)
    | InsertGateway Servers.CId
    | ContextTo Context
    | BouncesMsg Bounces.Msg
    | DatabaseMsg Database.Msg
    | NotificationsMsg Notifications.Msg
    | Request RequestMsg
    | HandleConnected
    | HandleDisconnected


type RequestMsg
    = LogoutRequest ResponseType
