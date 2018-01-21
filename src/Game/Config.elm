module Game.Config exposing (..)

import Time exposing (Time)
import Core.Flags as Core
import Core.Error as Error exposing (Error)
import Game.Meta.Types.Requester exposing (Requester)
import Game.Account.Finances.Shared exposing (..)
import Game.Account.Config as Account
import Game.Account.Models as Account
import Game.Account.Messages as Account
import Game.BackFlix.Config as BackFlix
import Game.Servers.Config as Servers
import Game.Servers.Models as Servers
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

    -- account
    , onConnected : String -> msg
    , onDisconnected : msg
    , onError : Error -> msg

    -- account.finances
    , onBALoginSuccess : Requester -> BankAccountData -> msg
    , onBALoginFailed : Requester -> msg
    , onBATransferSuccess : Requester -> msg
    , onBATransferFailed : Requester -> msg
    }


serversConfig : Time -> Core.Flags -> Config msg -> Servers.Config msg
serversConfig lastTick flags config =
    { flags = flags
    , toMsg = ServersMsg >> config.toMsg
    , batchMsg = config.batchMsg
    , lastTick = lastTick
    , onInventoryUsed =
        Inventory.HandleComponentUsed >> InventoryMsg >> config.toMsg
    , onInventoryFreed =
        Inventory.HandleComponentFreed >> InventoryMsg >> config.toMsg
    , onNewGateway =
        Account.HandleNewGateway >> AccountMsg >> config.toMsg
    }


accountConfig :
    ((Bool -> Account.Model) -> Account.Model)
    -> Time
    -> Core.Flags
    -> Config msg
    -> Account.Config msg
accountConfig fallToGateway lastTick flags config =
    { flags = flags
    , toMsg = AccountMsg >> config.toMsg
    , batchMsg = config.batchMsg
    , lastTick = lastTick
    , fallToGateway = fallToGateway
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
    , onBALoginSuccess = config.onBALoginSuccess
    , onBALoginFailed = config.onBALoginFailed
    , onBATransferSuccess = config.onBATransferSuccess
    , onBATransferFailed = config.onBATransferFailed
    }


webConfig : Core.Flags -> Servers.Model -> Config msg -> Web.Config msg
webConfig flags servers config =
    { flags = flags
    , toMsg = WebMsg >> config.toMsg
    , servers = servers
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
