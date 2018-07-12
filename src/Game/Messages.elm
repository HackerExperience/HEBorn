module Game.Messages exposing (..)

import Json.Decode exposing (Value)
import Game.Account.Messages as Account
import Game.Bank.Messages as Bank
import Game.Servers.Messages as Servers
import Game.Meta.Messages as Meta
import Game.Storyline.Messages as Story
import Game.Inventory.Messages as Inventory
import Game.Web.Messages as Web
import Game.BackFlix.Messages as BackFlix
import Requests.Types exposing (ResponseType)


type Msg
    = AccountMsg Account.Msg
    | ServersMsg Servers.Msg
    | BankMsg Bank.Msg
    | MetaMsg Meta.Msg
    | StoryMsg Story.Msg
    | InventoryMsg Inventory.Msg
    | WebMsg Web.Msg
    | BackFlixMsg BackFlix.Msg
    | Resync
    | ResyncRequest ResponseType
    | HandleJoinedAccount Value
