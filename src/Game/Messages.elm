module Game.Messages exposing (Msg(..), RequestMsg(..))

import Json.Decode exposing (Value)
import Game.Account.Messages as Account
import Game.Servers.Messages as Servers
import Game.Meta.Messages as Meta
import Game.Storyline.Messages as Story
import Game.Web.Messages as Web
import Events.Events as Events
import Requests.Types exposing (ResponseType)


type Msg
    = AccountMsg Account.Msg
    | ServersMsg Servers.Msg
    | MetaMsg Meta.Msg
    | StoryMsg Story.Msg
    | WebMsg Web.Msg
    | Resync
    | Event Events.Event
    | Request RequestMsg
    | HandleConnected
    | HandleJoinedAccount Value


type RequestMsg
    = ResyncRequest ResponseType
