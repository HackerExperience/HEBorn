module Core.Dispatcher
    exposing
        ( callAccount
        , callSoftware
        , callNetwork
        , callServer
        , callMeta
        , callWM
        , callDock
        , callExplorer
        , callSignUp
        , callLogin
        )

import Core.Messages exposing (CoreMsg(MsgGame, MsgOS, MsgApp))
import Game.Messages exposing (GameMsg(..))
import OS.Messages exposing (OSMsg(..))
import Apps.Messages exposing (AppMsg(..))
import Game.Meta.Messages as Meta
import Game.Account.Messages as Account
import Game.Software.Messages as Software
import Game.Network.Messages as Network
import Game.Server.Messages as Server
import OS.WindowManager.Messages as WM
import OS.Dock.Messages as Dock
import Apps.Explorer.Messages as Explorer
import Apps.SignUp.Messages as SignUp
import Apps.Login.Messages as Login


-- Would love to do something like below, but I can't =(
--
-- callGame =
--     { account = MsgGame (MsgAccount)
--     , software = MsgGame (MsgSoftware)
--     , network = MsgGame (MsgNetwork)
--     , server = MsgGame (MsgServer)
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


callSoftware : Software.SoftwareMsg -> CoreMsg
callSoftware msg =
    callGame (MsgSoftware msg)


callNetwork : Network.NetworkMsg -> CoreMsg
callNetwork msg =
    callGame (MsgNetwork msg)


callServer : Server.ServerMsg -> CoreMsg
callServer msg =
    callGame (MsgServer msg)


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


callLogin : Login.Msg -> CoreMsg
callLogin msg =
    callApps (MsgLogin msg)


callSignUp : SignUp.Msg -> CoreMsg
callSignUp msg =
    callApps (MsgSignUp msg)
