module Game.Account.Messages exposing (Msg(..), RequestMsg(..))

import Json.Decode exposing (Value)
import Events.Events as Events
import Game.Servers.Shared as Servers
import Requests.Types exposing (ResponseType)
import Game.Meta.Types exposing (..)
import Game.Account.Bounces.Messages as Bounces
import Game.Account.Database.Messages as Database


type Msg
    = DoLogout
    | SetGateway Servers.ID
    | SetEndpoint (Maybe Servers.ID)
    | ContextTo Context
    | BouncesMsg Bounces.Msg
    | DatabaseMsg Database.Msg
    | Request RequestMsg
    | Event Events.Event
    | Bootstrap Value -- TODO: remove this Value


type RequestMsg
    = LogoutRequest ResponseType
