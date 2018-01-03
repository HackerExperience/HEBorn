module Game.Messages exposing (Msg(..), RequestMsg(..))

import Json.Decode exposing (Value)
import Game.Account.Messages as Account
import Game.Servers.Messages as Servers
import Game.Meta.Messages as Meta
import Game.Storyline.Messages as Story
import Game.Inventory.Messages as Inventory
import Game.Web.Messages as Web
import Game.LogStream.Messages as LogFlix
import Requests.Types exposing (ResponseType)


type Msg
    = AccountMsg Account.Msg
    | ServersMsg Servers.Msg
    | MetaMsg Meta.Msg
    | StoryMsg Story.Msg
    | InventoryMsg Inventory.Msg
    | WebMsg Web.Msg
    | LogFlixMsg LogFlix.Msg
    | Resync
    | Request RequestMsg
    | HandleJoinedAccount Value


type RequestMsg
    = ResyncRequest ResponseType
