module Game.Account.Messages exposing (Msg(..))

import Game.Servers.Shared as Servers
import Game.Meta.Types.Context exposing (..)
import Game.Account.Bounces.Messages as Bounces
import Game.Account.Database.Messages as Database
import Game.Account.Finances.Messages as Finances
import Game.Account.Notifications.Messages as Notifications


type Msg
    = BouncesMsg Bounces.Msg
    | DatabaseMsg Database.Msg
    | NotificationsMsg Notifications.Msg
    | FinancesMsg Finances.Msg
    | HandleLogout
    | HandleSetGateway Servers.CId
    | HandleSetEndpoint (Maybe Servers.CId)
    | HandleSetContext Context
    | HandleNewGateway Servers.CId
    | HandleLogoutAndCrash ( String, String )
    | HandleTutorialCompleted Bool
    | HandleConnected
    | HandleDisconnected
