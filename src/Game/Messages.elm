module Game.Messages exposing (GameMsg(..))

import Game.Account.Messages
import Game.Servers.Messages
import Game.Network.Messages
import Game.Meta.Messages
import Events.Events as Events


type GameMsg
    = MsgAccount Game.Account.Messages.AccountMsg
    | MsgServers Game.Servers.Messages.Msg
    | MsgNetwork Game.Network.Messages.NetworkMsg
    | MsgMeta Game.Meta.Messages.MetaMsg
    | Event Events.Response
    | NoOp
