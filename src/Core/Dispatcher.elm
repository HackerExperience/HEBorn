module Core.Dispatcher
    exposing
        ( callAccount
        , callNetwork
        , callServer
        , callFilesystem
        , callProcesses
        , callLogs
        , callMeta
        )

import Core.Messages exposing (CoreMsg(MsgGame, MsgOS))
import Game.Messages exposing (GameMsg(..))
import OS.Messages exposing (OSMsg(..))
import Game.Meta.Messages as Meta
import Game.Account.Messages as Account
import Game.Network.Messages as Network
import Game.Servers.Messages as Server
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Models exposing (ServerID)


-- Would love to do something like below, but I can't =(
--
-- callGame =
--     { account = MsgGame (MsgAccount)
--     , network = MsgGame (MsgNetwork)
--     , server = MsgGame (MsgServers)
--     , meta = MsgGame (MsgMeta)
--     }


callGame : GameMsg -> CoreMsg
callGame =
    MsgGame


callOS : OSMsg -> CoreMsg
callOS =
    MsgOS


callAccount : Account.AccountMsg -> CoreMsg
callAccount msg =
    callGame (MsgAccount msg)


callNetwork : Network.NetworkMsg -> CoreMsg
callNetwork msg =
    callGame (MsgNetwork msg)


callServer : Server.ServerMsg -> CoreMsg
callServer msg =
    callGame (MsgServers msg)


callFilesystem : ServerID -> Filesystem.Msg -> CoreMsg
callFilesystem serverID msg =
    callServer (Server.MsgFilesystem serverID msg)


callProcesses : ServerID -> Processes.Msg -> CoreMsg
callProcesses serverID msg =
    callServer (Server.MsgProcess serverID msg)


callLogs : ServerID -> Logs.Msg -> CoreMsg
callLogs serverID msg =
    callServer (Server.MsgLog serverID msg)


callMeta : Meta.MetaMsg -> CoreMsg
callMeta msg =
    callGame (MsgMeta msg)
