module Game.Messages exposing (Msg(..), RequestMsg(..))

import Game.Account.Messages as Account
import Game.Servers.Messages as Servers
import Game.Meta.Messages as Meta
import Game.Web.Messages as Web
import Game.Storyline.Messages as Story
import Events.Events as Events
import Requests.Types exposing (ResponseType)
import Apps.Messages


type Msg
    = AccountMsg Account.Msg
    | ServersMsg Servers.Msg
    | MetaMsg Meta.Msg
    | WebMsg Web.Msg
    | StoryMsg Story.Msg
    | Request RequestMsg
    | Event Events.Event
    | NoOp


type RequestMsg
    = BootstrapRequest ResponseType
