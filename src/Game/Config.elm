module Game.Config exposing (..)

import Time exposing (Time)
import Json.Decode exposing (Value)
import Core.Flags as Core
import Core.Error as Error exposing (Error)
import Game.Meta.Types.Context as Context
import Game.Meta.Types.Desktop.Apps exposing (Requester)
import Game.Account.Bounces.Shared as Bounces
import Game.Account.Notifications.Shared as AccountNotifications
import Game.Servers.Notifications.Shared as ServersNotifications
import Game.Account.Config as Account
import Game.Account.Models as Account
import Game.Account.Messages as Account
import Game.Account.Finances.Models as Finances
import Game.BackFlix.Config as BackFlix
import Game.Bank.Config as Bank
import Game.Servers.Config as Servers
import Game.Servers.Models as Servers
import Game.Servers.Shared exposing (CId)
import Game.Servers.Messages as Servers
import Game.Inventory.Config as Inventory
import Game.Inventory.Messages as Inventory
import Game.Web.Config as Web
import Game.Storyline.Config as Story
import Game.Meta.Config as Meta
import Game.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , onJoinServer : CId -> Maybe Value -> msg
    , onError : Error -> msg
    , awaitEvent : String -> ( String, msg ) -> msg

    -- bank
    , onSendBankSessionId : String -> Requester -> msg
    , onJoinBank : Finances.AccountId -> String -> Value -> msg
    , onLeaveBank : Finances.AccountId -> String -> msg

    -- web
    , onJoinFailed : Requester -> msg

    -- servers
    , onNewGateway : CId -> msg

    -- account
    , onConnected : String -> msg
    , onDisconnected : msg

    -- account.notifications
    , onAccountToast : AccountNotifications.Content -> msg
    , onServerToast : CId -> ServersNotifications.Content -> msg

    -- account.bounces
    , onReloadBounce : Bounces.ID -> String -> msg
    , onReloadIfBounceLoaded : Bounces.ID -> msg
    }


serversConfig :
    Maybe CId
    -> Maybe ( CId, Servers.Server )
    -> Time
    -> Core.Flags
    -> Config msg
    -> Servers.Config msg
serversConfig activeCId activeGtw lastTick flags config =
    { flags = flags
    , toMsg = ServersMsg >> config.toMsg
    , batchMsg = config.batchMsg
    , lastTick = lastTick
    , onInventoryUsed =
        Inventory.HandleComponentUsed >> InventoryMsg >> config.toMsg
    , onInventoryFreed =
        Inventory.HandleComponentFreed >> InventoryMsg >> config.toMsg
    , onNewGateway =
        \cid ->
            config.batchMsg <|
                [ config.onNewGateway cid
                , config.toMsg <| AccountMsg <| Account.HandleNewGateway cid
                ]
    , onToast = config.onServerToast
    , onSetGatewayContext =
        Context.Endpoint
            |> Account.HandleSetContext
            |> AccountMsg
            |> config.toMsg
    , activeCId = activeCId
    , activeGateway = activeGtw
    }


accountConfig :
    Time
    -> Core.Flags
    -> Config msg
    -> Account.Config msg
accountConfig lastTick flags config =
    { flags = flags
    , toMsg = AccountMsg >> config.toMsg
    , batchMsg = config.batchMsg
    , lastTick = lastTick
    , onConnected = config.onConnected
    , onDisconnected = config.onDisconnected
    , onError = config.onError
    , onSetEndpoint =
        \cid param ->
            Servers.HandleSetEndpoint param
                |> Servers.ServerMsg cid
                |> ServersMsg
                |> config.toMsg

    -- account.finances
    , onReloadBounce = config.onReloadBounce
    , onReloadIfBounceLoaded = config.onReloadIfBounceLoaded
    , onToast = config.onAccountToast
    }


webConfig : Core.Flags -> Servers.Model -> Config msg -> Web.Config msg
webConfig flags servers config =
    { flags = flags
    , toMsg = WebMsg >> config.toMsg
    , batchMsg = config.batchMsg
    , servers = servers
    , onLogin = config.onJoinServer
    , onJoinedServer =
        \cid1 cid2 ->
            Servers.HandleSetEndpoint (Just cid2)
                |> Servers.ServerMsg cid1
                |> ServersMsg
                |> config.toMsg
    , onJoinFailed =
        config.onJoinFailed
    }


bankConfig :
    Account.Model
    -> Servers.Model
    -> Core.Flags
    -> Config msg
    -> Bank.Config msg
bankConfig account servers flags config =
    { flags = flags
    , toMsg = BankMsg >> config.toMsg
    , batchMsg = config.batchMsg
    , accountId = Account.getId account
    , finances = Account.getFinances account
    , activeGatewayCId = Account.getGateway account
    , awaitEvent = config.awaitEvent
    , activeBounce =
        account
            |> Account.getGateway
            |> Maybe.andThen (flip Servers.get servers)
            |> Maybe.andThen (flip Servers.getActiveBounce servers)
    , onLogin = config.onJoinBank
    , onLogout = config.onLeaveBank
    , onSendSessionId = config.onSendBankSessionId
    , onBankAccountUpdated = (\a b -> config.batchMsg []) -- Account.Msg <| DatabaseMsg Database.
    , onHackedBankAccountUpdated = (\a b -> config.batchMsg [])
    }


metaConfig : Config msg -> Meta.Config msg
metaConfig config =
    { toMsg = MetaMsg >> config.toMsg }


storyConfig : Account.ID -> Core.Flags -> Config msg -> Story.Config msg
storyConfig accountId flags config =
    { flags = flags
    , toMsg = StoryMsg >> config.toMsg
    , accountId = accountId
    }


inventoryConfig : Core.Flags -> Config msg -> Inventory.Config msg
inventoryConfig flags config =
    { flags = flags
    , toMsg = InventoryMsg >> config.toMsg
    }


backFlixConfig : Config msg -> BackFlix.Config msg
backFlixConfig config =
    { toMsg = BackFlixMsg >> config.toMsg }
