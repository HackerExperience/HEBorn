module Game.Account.Config exposing (..)

import Time exposing (Time)
import Core.Flags as Core
import Core.Error as Error exposing (Error)
import Game.Account.Models exposing (..)
import Game.Account.Bounces.Config as Bounces
import Game.Meta.Types.Requester exposing (Requester)
import Game.Servers.Shared exposing (CId)
import Game.Account.Finances.Shared exposing (..)
import Game.Account.Finances.Config as Finances
import Game.Account.Database.Config as Database
import Game.Account.Notifications.Config as Notifications
import Game.Account.Messages exposing (..)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , lastTick : Time
    , onConnected : String -> msg
    , onDisconnected : msg
    , onError : Error -> msg
    , onSetEndpoint : CId -> Maybe CId -> msg
    , fallToGateway : (Bool -> Model) -> Model
    , onBALoginSuccess : Requester -> BankAccountData -> msg
    , onBALoginFailed : Requester -> msg
    , onBATransferSuccess : Requester -> msg
    , onBATransferFailed : Requester -> msg
    }


financesConfig : ID -> Config msg -> Finances.Config msg
financesConfig accountId config =
    { flags = config.flags
    , toMsg = FinancesMsg >> config.toMsg
    , accountId = accountId
    , onBALoginSuccess = config.onBALoginSuccess
    , onBALoginFailed = config.onBALoginFailed
    , onBATransferSuccess = config.onBATransferSuccess
    , onBATransferFailed = config.onBATransferFailed
    }


databaseConfig : Config msg -> Database.Config msg
databaseConfig config =
    { flags = config.flags
    , toMsg = DatabaseMsg >> config.toMsg
    }


bouncesConfig : Config msg -> Bounces.Config msg
bouncesConfig config =
    { flags = config.flags
    , toMsg = BouncesMsg >> config.toMsg
    }


notificationsConfig : Config msg -> Notifications.Config msg
notificationsConfig config =
    { flags = config.flags
    , toMsg = NotificationsMsg >> config.toMsg
    , lastTick = config.lastTick
    }
