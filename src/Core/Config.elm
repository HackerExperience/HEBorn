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
import Game.Meta.Types.Context exposing (Context)
import Game.BackFlix.Messages as BackFlix
import Game.Account.Messages as Account
import Game.Account.Models as Account
import Game.Account.Finances.Messages as Finances
import Game.Account.Notifications.Messages as AccountNotifications
import Game.Account.Database.Messages as Database
import Game.Account.Database.Models as Database
import Game.Servers.Messages as Servers
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers exposing (CId)
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
import OS.SessionManager.Types as SessionManager
import OS.Toasts.Messages as Toast
import Setup.Config as Setup
import Setup.Messages as Setup
import Core.Flags exposing (Flags)
import Core.Error as Error exposing (Error)
import Core.Messages exposing (..)
import Setup.Config as Setup
import Game.Config as Game
import Game.Messages as Game
import Game.Models as Game
import Game.Account.Models as Account
import Game.Account.Messages as Account
import Game.Account.Notifications.Messages as AccNotif
import Game.Meta.Models as Meta
import Game.Meta.Types.Context exposing (..)
import Game.Servers.Messages as Servers
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Shared exposing (CId)
import Game.Servers.Notifications.Messages as SrvNotif
import Game.Storyline.Messages as Story
import Game.Storyline.Models as Story
import OS.Config as OS
import OS.Messages as OS
import OS.SessionManager.Messages as SessionManager
import OS.Toasts.Messages as Toast
import Apps.Messages as Apps
import Apps.Browser.Messages as Browser
import Game.Config as Game
import Game.Account.Models as Account
import Game.BackFlix.Models as BackFlix
import Game.Inventory.Models as Inventory
import Game.Servers.Models as Servers
import Game.Servers.Shared exposing (CId)
import Game.Storyline.Models as Story
import Core.Flags exposing (Flags)
import Core.Error as Error exposing (Error)
import Core.Messages exposing (..)


landingConfig : Bool -> Flags -> Landing.Config Msg
landingConfig windowLoaded flags =
    { flags = flags
    , toMsg = LandingMsg
    , onLogin = HandleBoot
    , windowLoaded = windowLoaded
    }


websocketConfig : Flags -> Ws.Config Msg
websocketConfig flags =
    { flags =
        flags
    , toMsg =
        WebsocketMsg
    , onConnected =
        BatchMsg
            [ HandleConnected
            , account Account.HandleConnected
            ]
    , onDisconnected =
        account <| Account.HandleDisconnected
    , onJoinedAccount =
        \value ->
            BatchMsg
                [ game <| Game.HandleJoinedAccount value
                , setup <| Setup.HandleJoinedAccount value
                ]
    , onJoinedServer =
        \cid value ->
            BatchMsg
                [ servers <| Servers.HandleJoinedServer cid value
                , setup <| Setup.HandleJoinedServer cid
                ]
    , onJoinFailedServer =
        Web.HandleJoinServerFailed >> web
    , onLeaved =
        \_ _ ->
            BatchMsg []
    , onEvent =
        HandleEvent
    }


eventsConfig : Events.Config Msg
eventsConfig =
    { forAccount =
        { onServerPasswordAcquired =
            \data ->
                BatchMsg
                    [ database <| Database.HandlePasswordAcquired data
                    , data
                        |> Browser.HandlePasswordAcquired
                        |> Apps.BrowserMsg
                        |> List.singleton
                        |> apps
                    ]
        , onStoryStepProceeded =
            Missions.HandleStepProceeded >> missions
        , onStoryEmailSent =
            \data ->
                BatchMsg
                    [ emails <| Emails.HandleNewEmail data
                    , data.personId
                        |> AccountNotifications.HandleNewEmail
                        |> accountNotif
                    ]
        , onStoryEmailReplyUnlocked =
            Emails.HandleReplyUnlocked >> emails
        , onBankAccountUpdated =
            uncurry Finances.HandleBankAccountUpdated >> finances
        , onBankAccountClosed =
            Finances.HandleBankAccountClosed >> finances
        , onDbAccountUpdated =
            uncurry Database.HandleDatabaseAccountUpdated >> database
        , onDbAccountRemoved =
            Database.HandleDatabaseAccountRemoved >> database
        , onTutorialFinished =
            .completed >> Account.HandleTutorialCompleted >> account
        }
    , forBackFlix =
        { onNewLog =
            BackFlix.HandleCreate >> backflix
        }
    , forServer =
        { onFileAdded =
            \cid ( id, data ) ->
                filesystem cid id <| uncurry Filesystem.HandleAdded data
        , onFileDownloaded =
            -- not implemented yet
            \cid ( id, data ) -> BatchMsg []
        , onProcessCreated =
            \cid data ->
                processes cid <| Processes.HandleProcessStarted data
        , onProcessCompleted =
            \cid data ->
                processes cid <| Processes.HandleProcessConclusion data
        , onProcessesRecalcado =
            \cid data ->
                processes cid <| Processes.HandleProcessesChanged data
        , onBruteforceFailed =
            \cid data ->
                processes cid <| Processes.HandleBruteforceFailed data
        , onLogCreated =
            \cid data ->
                logs cid <| uncurry Logs.HandleCreated data
        , onMotherboardUpdated =
            \cid data ->
                hardware cid <| Hardware.HandleMotherboardUpdated data
        }
    }


gameConfig : Game.Config Msg
gameConfig =
    { toMsg = GameMsg
    , batchMsg = BatchMsg

    -- game & web
    , onJoinServer =
        \cid payload ->
            ws <| Ws.HandleJoin (ServerChannel cid) payload
    , onError =
        HandleCrash

    -- web
    , onDNS =
        \response { sessionId, windowId, context, tabId } ->
            Browser.HandleFetched response
                |> Browser.SomeTabMsg tabId
                |> browser ( sessionId, windowId ) context
    , onJoinFailed =
        \{ sessionId, windowId, context, tabId } ->
            Browser.LoginFailed
                |> Browser.SomeTabMsg tabId
                |> browser ( sessionId, windowId ) context

    --- account
    , onConnected =
        \accountId ->
            BatchMsg
                [ ws <| Ws.HandleJoin (AccountChannel accountId) Nothing
                , ws <| Ws.HandleJoin BackFlixChannel Nothing
                ]
    , onDisconnected =
        HandleShutdown

    -- account.notifications
    , onAccountToast =
        Toast.HandleAccount >> toast
    , onServerToast =
        \cid -> Toast.HandleServers cid >> toast

    -- account.finances
    , onBALoginSuccess =
        \data { sessionId, windowId, context, tabId } ->
            Browser.LoginFailed
                |> Browser.SomeTabMsg tabId
                |> browser ( sessionId, windowId ) context
    , onBALoginFailed =
        \{ sessionId, windowId, context, tabId } ->
            Browser.HandleBankLoginError
                |> Browser.SomeTabMsg tabId
                |> browser ( sessionId, windowId ) context
    , onBATransferSuccess =
        \{ sessionId, windowId, context, tabId } ->
            Browser.HandleBankTransfer
                |> Browser.SomeTabMsg tabId
                |> browser ( sessionId, windowId ) context
    , onBATransferFailed =
        \{ sessionId, windowId, context, tabId } ->
            Browser.HandleBankTransferError
                |> Browser.SomeTabMsg tabId
                |> browser ( sessionId, windowId ) context
    }


setupConfig : String -> CId -> Flags -> Setup.Config Msg
setupConfig accountId mainframe flags =
    { toMsg = SetupMsg
    , accountId = accountId
    , mainframe = mainframe
    , flags = flags
    }


osConfig :
    Game.Model
    -> ( CId, Server )
    -> Context
    -> ( CId, Server )
    -> OS.Config Msg
osConfig game (( cid, _ ) as srv) ctx gtw =
    { toMsg = OSMsg
    , flags = Game.getFlags game
    , account = Game.getAccount game
    , servers = Game.getServers game
    , story = Game.getStory game
    , inventory = Game.getInventory game
    , backFlix = .logs <| Game.getBackFlix game
    , lastTick = Meta.getLastTick <| Game.getMeta <| game
    , activeServer = srv
    , activeContext = ctx
    , activeGateway = gtw
    , onLogout =
        Account.HandleLogout
            |> Game.AccountMsg
            |> GameMsg
    , onSetGateway =
        Account.HandleSetGateway
            >> Game.AccountMsg
            >> GameMsg
    , onSetEndpoint =
        Account.HandleSetEndpoint
            >> Game.AccountMsg
            >> GameMsg
    , onSetContext =
        Account.HandleSetContext
            >> Game.AccountMsg
            >> GameMsg
    , onSetBounce =
        Servers.HandleSetBounce
            >> Servers.ServerMsg cid
            >> Game.ServersMsg
            >> GameMsg
    , onSetStoryMode =
        Story.HandleSetMode
            >> Game.StoryMsg
            >> GameMsg
    , onReadAllAccountNotifications =
        AccNotif.HandleReadAll
            |> Account.NotificationsMsg
            |> Game.AccountMsg
            |> GameMsg
    , onReadAllServerNotifications =
        SrvNotif.HandleReadAll
            |> Servers.NotificationsMsg
            |> Servers.ServerMsg cid
            |> Game.ServersMsg
            |> GameMsg
    , onSetActiveNIP =
        Servers.HandleSetActiveNIP
            >> Servers.ServerMsg cid
            >> Game.ServersMsg
            >> GameMsg
    }



-- helpers


ws : Ws.Msg -> Msg
ws =
    WebsocketMsg


setup : Setup.Msg -> Msg
setup =
    SetupMsg


game : Game.Msg -> Msg
game =
    GameMsg


backflix : BackFlix.Msg -> Msg
backflix =
    Game.BackFlixMsg >> game


account : Account.Msg -> Msg
account =
    Game.AccountMsg >> game


accountNotif : AccountNotifications.Msg -> Msg
accountNotif =
    Account.NotificationsMsg >> account


database : Database.Msg -> Msg
database =
    Account.DatabaseMsg >> account


servers : Servers.Msg -> Msg
servers =
    Game.ServersMsg >> game


server : CId -> Servers.ServerMsg -> Msg
server cid =
    Servers.ServerMsg cid >> servers


serverNotif : CId -> ServersNotifications.Msg -> Msg
serverNotif cid =
    Servers.NotificationsMsg >> server cid


filesystem : CId -> Servers.StorageId -> Filesystem.Msg -> Msg
filesystem cid id =
    Servers.FilesystemMsg id >> server cid


processes : CId -> Processes.Msg -> Msg
processes id =
    Servers.ProcessesMsg >> server id


hardware : CId -> Hardware.Msg -> Msg
hardware id =
    Servers.HardwareMsg >> server id


logs : CId -> Logs.Msg -> Msg
logs id =
    Servers.LogsMsg >> server id


web : Web.Msg -> Msg
web =
    Game.WebMsg >> game


storyline : Storyline.Msg -> Msg
storyline =
    Game.StoryMsg >> game


missions : Missions.Msg -> Msg
missions =
    Storyline.MissionsMsg >> storyline


emails : Emails.Msg -> Msg
emails =
    Storyline.EmailsMsg >> storyline


finances : Finances.Msg -> Msg
finances =
    Account.FinancesMsg >> account


sessionManager : SessionManager.Msg -> Msg
sessionManager =
    OS.SessionManagerMsg >> os


os : OS.Msg -> Msg
os =
    OSMsg


toast : Toast.Msg -> Msg
toast =
    OS.ToastsMsg >> os


apps : List Apps.Msg -> Msg
apps =
    SessionManager.EveryAppMsg >> sessionManager


browser :
    SessionManager.WindowRef
    -> Context
    -> Browser.Msg
    -> Msg
browser windowRef context =
    Apps.BrowserMsg >> app windowRef context


app :
    SessionManager.WindowRef
    -> Context
    -> Apps.Msg
    -> Msg
app windowRef context =
    SessionManager.AppMsg windowRef context
        >> sessionManager
