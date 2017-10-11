module Game.Account.Messages exposing (Msg(..), RequestMsg(..))

import Json.Decode exposing (Value)
import Requests.Types exposing (ResponseType)
import Game.Servers.Shared as Servers
import Game.Meta.Types exposing (..)
import Game.Account.Bounces.Messages as Bounces
import Game.Account.Database.Messages as Database
import Game.Notifications.Messages as Notifications
import Game.Network.Types exposing (NIP)


type Msg
    = DoLogout
    | DoCrash String String
    | SetGateway NIP
    | SetEndpoint (Maybe NIP)
    | InsertGateway NIP
    | InsertEndpoint NIP
    | ContextTo Context
    | BouncesMsg Bounces.Msg
    | DatabaseMsg Database.Msg
    | NotificationsMsg Notifications.Msg
    | Request RequestMsg
    | HandleConnect
    | HandleDisconnect


type RequestMsg
    = LogoutRequest ResponseType
