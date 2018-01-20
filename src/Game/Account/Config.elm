module Game.Account.Config exposing (..)

import Time exposing (Time)
import Core.Flags as Core
import Game.Account.Models exposing (..)
import Game.Account.Bounces.Config as Bounces
import Game.Account.Finances.Config as Finances
import Game.Account.Database.Config as Database
import Game.Account.Notifications.Config as Notifications
import Game.Account.Messages exposing (..)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , lastTick : Time
    , fallToGateway : (Bool -> Model) -> Model
    }


financesConfig : ID -> Config msg -> Finances.Config msg
financesConfig accountId config =
    { flags = config.flags
    , toMsg = FinancesMsg >> config.toMsg
    , accountId = accountId
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
