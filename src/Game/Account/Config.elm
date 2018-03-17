module Game.Account.Config exposing (..)

import Time exposing (Time)
import Core.Flags as Core
import Core.Error as Error exposing (Error)
import Game.Account.Models exposing (..)
import Game.Account.Messages exposing (..)
import Game.Account.Bounces.Config as Bounces
import Game.Account.Database.Config as Database
import Game.Account.Database.Models as Database
import Game.Account.Finances.Requests.Login as BankLoginRequest
import Game.Account.Finances.Requests.Transfer as BankTransferRequest
import Game.Account.Finances.Config as Finances
import Game.Account.Notifications.Config as Notifications
import Game.Account.Notifications.Shared as Notifications
import Game.Meta.Types.Desktop.Apps exposing (Requester)
import Game.Servers.Shared exposing (CId)
import Game.Account.Bounces.Shared as Bounces


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , lastTick : Time

    -- events
    , onConnected : String -> msg
    , onDisconnected : msg
    , onError : Error -> msg
    , onSetEndpoint : CId -> Maybe CId -> msg

    -- account.finances
    , onBankAccountLogin : BankLoginRequest.Data -> Requester -> msg
    , onBankAccountTransfer : BankTransferRequest.Data -> Requester -> msg

    -- account.bounces
    , onReloadBounce : Bounces.ID -> String -> msg
    , onReloadIfBounceLoaded : Bounces.ID -> msg

    -- account.notifications
    , onToast : Notifications.Content -> msg
    }


financesConfig : ID -> Config msg -> Finances.Config msg
financesConfig accountId config =
    { flags = config.flags
    , toMsg = FinancesMsg >> config.toMsg
    , accountId = accountId
    , onBankAccountLogin = config.onBankAccountLogin
    , onBankAccountTransfer = config.onBankAccountTransfer
    }


databaseConfig : Config msg -> Database.Config msg
databaseConfig config =
    { flags = config.flags
    , toMsg = DatabaseMsg >> config.toMsg
    , lastTick = config.lastTick
    }


bouncesConfig : Database.Model -> ID -> Config msg -> Bounces.Config msg
bouncesConfig database accountId config =
    { flags = config.flags
    , batchMsg = config.batchMsg
    , toMsg = BouncesMsg >> config.toMsg
    , database = database
    , accountId = accountId
    , onReloadBounce = config.onReloadBounce
    , onReloadIfBounceLoaded = config.onReloadIfBounceLoaded
    }


notificationsConfig : Config msg -> Notifications.Config msg
notificationsConfig config =
    { flags = config.flags
    , toMsg = NotificationsMsg >> config.toMsg
    , lastTick = config.lastTick
    , onToast = config.onToast
    }
