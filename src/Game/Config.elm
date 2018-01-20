module Game.Config exposing (..)

import Time exposing (Time)
import Core.Flags as Core
import Game.Account.Config as Account
import Game.Account.Models as Account
import Game.BackFlix.Config as BackFlix
import Game.Servers.Config as Servers
import Game.Servers.Models as Servers
import Game.Inventory.Config as Inventory
import Game.Web.Config as Web
import Game.Storyline.Config as Story
import Game.Meta.Config as Meta
import Game.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    }


serversConfig : Time -> Core.Flags -> Config msg -> Servers.Config msg
serversConfig lastTick flags config =
    { flags = flags
    , toMsg = ServersMsg >> config.toMsg
    , batchMsg = config.batchMsg
    , lastTick = lastTick
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
    , lastTick = lastTick
    , fallToGateway = fallToGateway
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
