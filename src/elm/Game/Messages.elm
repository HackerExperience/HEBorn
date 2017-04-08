module Game.Messages exposing (GameMsg(..), call)


import Events.Models
import Requests.Models
import OS.Messages

import Game.Account.Messages
import Game.Server.Messages
import Game.Network.Messages
import Game.Software.Messages
import Game.Meta.Messages


type GameMsg
    = MsgAccount Game.Account.Messages.AccountMsg
    | MsgSoftware Game.Software.Messages.SoftwareMsg
    | MsgServer Game.Server.Messages.ServerMsg
    | MsgNetwork Game.Network.Messages.NetworkMsg
    | MsgMeta Game.Meta.Messages.MetaMsg
    | Event Events.Models.Event
    | Request Requests.Models.Request
    | Response Requests.Models.Request Requests.Models.Response
    | ToOS OS.Messages.OSMsg
    | NoOp


call =
    { account = MsgAccount
    , software = MsgSoftware
    , network = MsgNetwork
    , server = MsgServer
    , meta = MsgMeta
    }
