module Core.Config
    exposing
        ( landingConfig
        , websocketConfig
        , eventsConfig
        , gameConfig
        , setupConfig
        , osConfig
        )

import Time exposing (Time)
import Events.Config as Events
import Apps.Messages as Apps
import Apps.Browser.Messages as Browser
import Driver.Websocket.Config as Ws
import Driver.Websocket.Channels exposing (Channel(..))
import Driver.Websocket.Messages as Ws
import Game.Config as Game
import Game.Messages as Game
import Game.BackFlix.Messages as BackFlix
import Game.Account.Messages as Account
import Game.Account.Models as Account
import Game.Account.Finances.Messages as Finances
import Game.Account.Notifications.Messages as AccountNotifications
import Game.Account.Database.Messages as Database
import Game.Account.Database.Models as Database
import Game.Servers.Messages as Servers
import Game.Servers.Models as Servers
import Game.Servers.Shared exposing (CId)
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Hardware.Messages as Hardware
import Game.Servers.Notifications.Messages as ServersNotifications
import Game.Storyline.Messages as Storyline
import Game.Storyline.Models as Storyline
import Game.Storyline.Missions.Messages as Missions
import Game.Storyline.Emails.Messages as Emails
import Game.Web.Config as Web
import Game.Web.Messages as Web
import Landing.Config as Landing
import OS.Config as OS
import OS.Messages as OS
import OS.SessionManager.Messages as SessionManager
import OS.Toasts.Messages as Toast
import Setup.Config as Setup
import Setup.Messages as Setup
import Core.Flags exposing (Flags)
import Core.Error as Error exposing (Error)
import Core.Messages exposing (..)


-- this module may be optimized using the same techniques
-- used in the old Subscribers.Helpers


landingConfig : Bool -> Flags -> Landing.Config Msg
landingConfig windowLoaded flags =
    { flags = flags
    , toMsg = LandingMsg
    , onLogin = HandleBoot
    , windowLoaded = windowLoaded
    }


websocketConfig : Flags -> Ws.Config Msg
websocketConfig flags =
    { flags = flags
    , toMsg = WebsocketMsg
    , onConnected =
        MultiMsg
            [ HandleConnected
            , Account.HandleConnected
                |> Game.AccountMsg
                |> GameMsg
            ]
    , onDisconnected =
        Account.HandleDisconnected
            |> Game.AccountMsg
            |> GameMsg
    , onJoinedAccount =
        \value ->
            MultiMsg
                [ value
                    |> Game.HandleJoinedAccount
                    |> GameMsg
                , value
                    |> Setup.HandleJoinedAccount
                    |> SetupMsg
                ]
    , onJoinedServer =
        \cid value ->
            MultiMsg
                [ value
                    |> Servers.HandleJoinedServer cid
                    |> Game.ServersMsg
                    |> GameMsg
                , SetupMsg <| Setup.HandleJoinedServer cid
                ]
    , onJoinFailedServer =
        Web.HandleJoinServerFailed
            >> Game.WebMsg
            >> GameMsg
    , onLeaved = (always <| always <| MultiMsg [])
    , onEvent = HandleEvent
    }


eventsConfig : Events.Config Msg
eventsConfig =
    { forAccount =
        { onServerPasswordAcquired =
            \data ->
                MultiMsg
                    [ data
                        |> Database.HandlePasswordAcquired
                        |> Account.DatabaseMsg
                        |> Game.AccountMsg
                        |> GameMsg
                    , data
                        |> Browser.HandlePasswordAcquired
                        |> Apps.BrowserMsg
                        |> List.singleton
                        |> SessionManager.EveryAppMsg
                        |> OS.SessionManagerMsg
                        |> OSMsg
                    ]
        , onStoryStepProceeded =
            Missions.HandleStepProceeded
                >> Storyline.MissionsMsg
                >> Game.StoryMsg
                >> GameMsg
        , onStoryEmailSent =
            \data ->
                MultiMsg
                    [ data
                        |> Emails.HandleNewEmail
                        |> Storyline.EmailsMsg
                        |> Game.StoryMsg
                        |> GameMsg
                    , data.personId
                        |> AccountNotifications.HandleNewEmail
                        |> Account.NotificationsMsg
                        |> Game.AccountMsg
                        |> GameMsg
                    ]
        , onStoryEmailReplyUnlocked =
            Emails.HandleReplyUnlocked
                >> Storyline.EmailsMsg
                >> Game.StoryMsg
                >> GameMsg
        , onBankAccountUpdated =
            uncurry Finances.HandleBankAccountUpdated
                >> Account.FinancesMsg
                >> Game.AccountMsg
                >> GameMsg
        , onBankAccountClosed =
            Finances.HandleBankAccountClosed
                >> Account.FinancesMsg
                >> Game.AccountMsg
                >> GameMsg
        , onDbAccountUpdated =
            uncurry Database.HandleDatabaseAccountUpdated
                >> Account.DatabaseMsg
                >> Game.AccountMsg
                >> GameMsg
        , onDbAccountRemoved =
            Database.HandleDatabaseAccountRemoved
                >> Account.DatabaseMsg
                >> Game.AccountMsg
                >> GameMsg
        , onTutorialFinished =
            .completed
                >> Account.HandleTutorialCompleted
                >> Game.AccountMsg
                >> GameMsg
        }
    , forBackFlix =
        { onNewLog =
            BackFlix.HandleCreate
                >> Game.BackFlixMsg
                >> GameMsg
        }
    , forServer =
        { onFileAdded =
            \cid ( storageId, data ) ->
                data
                    |> uncurry Filesystem.HandleAdded
                    |> Servers.FilesystemMsg storageId
                    |> Servers.ServerMsg cid
                    |> Game.ServersMsg
                    |> GameMsg
        , onFileDownloaded =
            -- not implemented yet
            \cid ( storageId, data ) -> MultiMsg []
        , onProcessCreated =
            \cid data ->
                data
                    |> Processes.HandleProcessStarted
                    |> Servers.ProcessesMsg
                    |> Servers.ServerMsg cid
                    |> Game.ServersMsg
                    |> GameMsg
        , onProcessCompleted =
            \cid data ->
                data
                    |> Processes.HandleProcessConclusion
                    |> Servers.ProcessesMsg
                    |> Servers.ServerMsg cid
                    |> Game.ServersMsg
                    |> GameMsg
        , onProcessesRecalcado =
            \cid data ->
                data
                    |> Processes.HandleProcessesChanged
                    |> Servers.ProcessesMsg
                    |> Servers.ServerMsg cid
                    |> Game.ServersMsg
                    |> GameMsg
        , onBruteforceFailed =
            \cid data ->
                data
                    |> Processes.HandleBruteforceFailed
                    |> Servers.ProcessesMsg
                    |> Servers.ServerMsg cid
                    |> Game.ServersMsg
                    |> GameMsg
        , onLogCreated =
            \cid data ->
                data
                    |> uncurry Logs.HandleCreated
                    |> Servers.LogsMsg
                    |> Servers.ServerMsg cid
                    |> Game.ServersMsg
                    |> GameMsg
        , onMotherboardUpdated =
            \cid data ->
                data
                    |> Hardware.HandleMotherboardUpdated
                    |> Servers.HardwareMsg
                    |> Servers.ServerMsg cid
                    |> Game.ServersMsg
                    |> GameMsg
        }
    }


gameConfig : Game.Config Msg
gameConfig =
    { toMsg = GameMsg
    , batchMsg = MultiMsg

    -- game & web
    , onJoinServer =
        \cid payload ->
            payload
                |> Ws.HandleJoin (ServerChannel cid)
                |> WebsocketMsg
    , onError =
        HandleCrash

    -- web
    , onDNS =
        \response { sessionId, windowId, context, tabId } ->
            Browser.HandleFetched response
                |> Browser.SomeTabMsg tabId
                |> Apps.BrowserMsg
                |> SessionManager.AppMsg ( sessionId, windowId ) context
                |> OS.SessionManagerMsg
                |> OSMsg
    , onJoinFailed =
        \{ sessionId, windowId, context, tabId } ->
            Browser.LoginFailed
                |> Browser.SomeTabMsg tabId
                |> Apps.BrowserMsg
                |> SessionManager.AppMsg ( sessionId, windowId ) context
                |> OS.SessionManagerMsg
                |> OSMsg

    --- account
    , onConnected =
        \accountId ->
            MultiMsg
                [ Nothing
                    |> Ws.HandleJoin (AccountChannel accountId)
                    |> WebsocketMsg
                , Nothing
                    |> Ws.HandleJoin BackFlixChannel
                    |> WebsocketMsg
                ]
    , onDisconnected =
        HandleShutdown

    -- account.notifications
    , onAccountToast =
        Toast.HandleAccount
            >> OS.ToastsMsg
            >> OSMsg
    , onServerToast =
        \cid ->
            Toast.HandleServers cid
                >> OS.ToastsMsg
                >> OSMsg

    -- account.finances -- REVIEW
    , onBALoginSuccess =
        \data { sessionId, windowId, context, tabId } ->
            Browser.LoginFailed
                |> Browser.SomeTabMsg tabId
                |> Apps.BrowserMsg
                |> SessionManager.AppMsg ( sessionId, windowId ) context
                |> OS.SessionManagerMsg
                |> OSMsg
    , onBALoginFailed =
        \{ sessionId, windowId, context, tabId } ->
            Browser.HandleBankLoginError
                |> Browser.SomeTabMsg tabId
                |> Apps.BrowserMsg
                |> SessionManager.AppMsg ( sessionId, windowId ) context
                |> OS.SessionManagerMsg
                |> OSMsg
    , onBATransferSuccess =
        \{ sessionId, windowId, context, tabId } ->
            Browser.HandleBankTransfer
                |> Browser.SomeTabMsg tabId
                |> Apps.BrowserMsg
                |> SessionManager.AppMsg ( sessionId, windowId ) context
                |> OS.SessionManagerMsg
                |> OSMsg
    , onBATransferFailed =
        \{ sessionId, windowId, context, tabId } ->
            Browser.HandleBankTransferError
                |> Browser.SomeTabMsg tabId
                |> Apps.BrowserMsg
                |> SessionManager.AppMsg ( sessionId, windowId ) context
                |> OS.SessionManagerMsg
                |> OSMsg
    }


setupConfig : String -> Maybe CId -> Flags -> Setup.Config Msg
setupConfig accountId mainframe flags =
    { toMsg = SetupMsg
    , accountId = accountId
    , mainframe = mainframe
    , flags = flags
    }


osConfig :
    Account.Model
    -> Storyline.Model
    -> Time
    -> Servers.Server
    -> OS.Config Msg
osConfig account story lastTick activeServer =
    { toMsg = OSMsg
    , account = account
    , activeServer = activeServer
    , story = story
    , lastTick = lastTick
    }
