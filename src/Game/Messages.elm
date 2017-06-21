module Game.Messages exposing (Msg(..))

import Game.Account.Messages as Account
import Game.Servers.Messages as Servers
import Game.Network.Messages as Network
import Game.Meta.Messages as Meta
import Events.Events as Events


type Msg
    = AccountMsg Account.Msg
    | ServersMsg Servers.Msg
    | NetworkMsg Network.Msg
    | MetaMsg Meta.Msg
    | Event Events.Response
    | NoOp
