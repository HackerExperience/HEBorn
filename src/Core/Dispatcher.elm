module Core.Dispatcher
    exposing
        ( callAccount
        , callNetwork
        , callServer
        , callFilesystem
        , callMeta
        )

import Core.Messages exposing (CoreMsg(MsgGame, MsgOS))
import Game.Messages exposing (GameMsg(..))
import OS.Messages exposing (OSMsg(..))
import Apps.Messages exposing (AppMsg(..))
import Game.Meta.Messages as Meta
import Game.Account.Messages as Account
import Game.Network.Messages as Network
import Game.Servers.Messages as Server
import Game.Servers.Filesystem.Messages as Filesystem
import OS.SessionManager.WindowManager.Messages as WM
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


callFilesystem : ServerID -> Filesystem.FilesystemMsg -> CoreMsg
callFilesystem serverID msg =
    callServer (Server.MsgFilesystem serverID msg)


callMeta : Meta.MetaMsg -> CoreMsg
callMeta msg =
    callGame (MsgMeta msg)
