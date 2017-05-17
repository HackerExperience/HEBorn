module Core.Dispatcher
    exposing
        ( callAccount
        , callNetwork
        , callServer
        , callFilesystem
        , callMeta
        , callWM
        , callDock
        , callExplorer
        , callLogViewer
        , callInstance
        )

import Core.Messages exposing (CoreMsg(MsgGame, MsgOS, MsgApp))
import Game.Messages exposing (GameMsg(..))
import OS.Messages exposing (OSMsg(..))
import Apps.Messages exposing (AppMsg(..))
import Game.Meta.Messages as Meta
import Game.Account.Messages as Account
import Game.Network.Messages as Network
import Game.Servers.Messages as Server
import Game.Servers.Filesystem.Messages as Filesystem
import OS.WindowManager.Messages as WM
import OS.Dock.Messages as Dock
import Apps.Explorer.Messages as Explorer
import Game.Servers.Models exposing (ServerID)
import Apps.LogViewer.Messages as LogViewer
import Apps.Browser.Messages as Browser
import OS.WindowManager.Windows exposing (GameWindow(..))


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


callApps : AppMsg -> CoreMsg
callApps =
    MsgApp


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


callWM : WM.Msg -> CoreMsg
callWM msg =
    callOS (MsgWM msg)


callDock : Dock.Msg -> CoreMsg
callDock msg =
    callOS (MsgDock msg)


callExplorer : Explorer.Msg -> CoreMsg
callExplorer msg =
    callApps (MsgExplorer msg)


callLogViewer : LogViewer.Msg -> CoreMsg
callLogViewer msg =
    callApps (MsgLogViewer msg)


callBrowser : Browser.Msg -> CoreMsg
callBrowser msg =
    callApps (MsgBrowser msg)


callInstance msg =
    callApps msg
