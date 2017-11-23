module Game.Account.Messages exposing (Msg(..), RequestMsg(..))

import Json.Decode exposing (Value)
import Requests.Types exposing (ResponseType)
import Game.Servers.Shared as Servers
import Game.Meta.Types.Context exposing (..)
import Game.Account.Bounces.Messages as Bounces
import Game.Account.Database.Messages as Database
import Game.Notifications.Messages as Notifications


type Msg
    = BouncesMsg Bounces.Msg
    | DatabaseMsg Database.Msg
    | NotificationsMsg Notifications.Msg
    | Request RequestMsg
    | HandleLogout
    | HandleSetGateway Servers.CId
    | HandleSetEndpoint (Maybe Servers.CId)
    | HandleSetContext Context
    | HandleNewGateway Servers.CId
    | HandleLogoutAndCrash ( String, String )
    | HandleConnected
    | HandleDisconnected


type RequestMsg
    = LogoutRequest ResponseType
