module Game.Messages exposing (GameMsg(..))

import Game.Account.Messages
import Game.Servers.Messages
import Game.Network.Messages
import Game.Meta.Messages


type GameMsg
    = MsgAccount Game.Account.Messages.AccountMsg
    | MsgServers Game.Servers.Messages.ServerMsg
    | MsgNetwork Game.Network.Messages.NetworkMsg
    | MsgMeta Game.Meta.Messages.MetaMsg
    | NoOp
