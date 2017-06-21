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

import Core.Messages exposing (..)
import Game.Messages as Game
import OS.Messages as OS
import Game.Meta.Messages as Meta
import Game.Account.Messages as Account
import Game.Network.Messages as Network
import Game.Servers.Messages as Servers
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Models exposing (ServerID)


callGame : Game.Msg -> Msg
callGame =
    GameMsg


callOS : OS.Msg -> Msg
callOS =
    OSMsg


callAccount : Account.Msg -> Msg
callAccount msg =
    callGame (Game.AccountMsg msg)


callNetwork : Network.Msg -> Msg
callNetwork msg =
    callGame (Game.NetworkMsg msg)


callServer : Servers.Msg -> Msg
callServer msg =
    callGame (Game.ServersMsg msg)


callFilesystem : ServerID -> Filesystem.Msg -> Msg
callFilesystem serverID msg =
    callServer (Servers.FilesystemMsg serverID msg)


callProcesses : ServerID -> Processes.Msg -> Msg
callProcesses serverID msg =
    callServer (Servers.ProcessMsg serverID msg)


callLogs : ServerID -> Logs.Msg -> Msg
callLogs serverID msg =
    callServer (Servers.LogMsg serverID msg)


callMeta : Meta.Msg -> Msg
callMeta msg =
    callGame (Game.MetaMsg msg)
