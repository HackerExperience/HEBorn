module Core.Config
    exposing
        ( landingConfig
        , websocketConfig
        , eventsConfig
        , gameConfig
        , setupConfig
        , osConfig
        )

import Color
import ContextMenu exposing (ContextMenu)
import Driver.Websocket.Config as Ws
import Driver.Websocket.Channels exposing (Channel(..))
import Driver.Websocket.Messages as Ws
import Utils.Core exposing (..)
import Core.Flags exposing (Flags)
import Core.Messages exposing (..)
import Events.Config as Events
import Landing.Config as Landing
import Setup.Config as Setup
import Setup.Messages as Setup
import Game.Config as Game
import Game.Messages as Game
import Game.Models as Game
import Game.Account.Models as Account
import Game.Account.Messages as Account
import Game.Account.Bounces.Messages as Bounces
import Game.Account.Database.Messages as Database
import Game.Account.Finances.Messages as Finances
import Game.Account.Notifications.Messages as AccountNotifications
import Game.BackFlix.Messages as BackFlix
import Game.Meta.Models as Meta
import Game.Meta.Types.Context exposing (Context)
import Game.Servers.Messages as Servers
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Hardware.Messages as Hardware
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Notifications.Messages as ServerNotifications
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Shared as Servers exposing (CId)
import Game.Storyline.Missions.Actions as MissionsActions
import Game.Storyline.Messages as Storyline
import Game.Storyline.Emails.Messages as Emails
import Game.Storyline.Missions.Messages as Missions
import Game.Web.Messages as Web
import OS.Config as OS
import OS.Messages as OS
import OS.SessionManager.Messages as SessionManager
import OS.SessionManager.Types as SessionManager
import OS.Toasts.Messages as Toast
import Apps.Messages as Apps
import Apps.Browser.Messages as Browser
import Apps.BounceManager.Messages as BounceManager


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
        \cid value -> servers <| Servers.HandleJoinedServer cid value
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
        , onStoryEmailReplySent =
            Emails.HandleReplySent >> emails
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
        , onBounceCreated =
            \( id, bounce ) ->
                Bounces.HandleCreated id bounce
                    |> bounces
        , onBounceUpdated =
            \( id, bounce ) ->
                Bounces.HandleUpdated id bounce
                    |> bounces
        , onBounceRemoved =
            \id ->
                Bounces.HandleRemoved id
                    |> bounces
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
            Browser.HandleLoginFailed
                |> Browser.SomeTabMsg tabId
                |> browser ( sessionId, windowId ) context

    -- servers
    , onNewGateway =
        Setup.HandleJoinedServer >> setup

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
        Toast.HandleServers >>> toast

    -- account.finances
    , onBALoginSuccess =
        \data { sessionId, windowId, context, tabId } ->
            Browser.HandleBankLogin data
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


setupConfig : String -> Maybe CId -> Flags -> Setup.Config Msg
setupConfig accountId mainframe flags =
    { toMsg = SetupMsg
    , batchMsg = BatchMsg
    , accountId = accountId
    , mainframe = mainframe
    , onServerSetName =
        \cid -> Servers.HandleSetName >> server cid
    , flags = flags
    , onError = HandleCrash
    , onPlay = HandlePlay
    }


osConfig :
    Game.Model
    -> ContextMenuMagic
    -> ( CId, Server )
    -> Context
    -> ( CId, Server )
    -> OS.Config Msg
osConfig game menu (( sCId, _ ) as srv) ctx (( gCId, _ ) as gtw) =
    { toMsg = OSMsg
    , batchMsg = BatchMsg
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
    , menuView = ContextMenu.view menuConfig MenuMsg identity menu
    , menuAttr = ContextMenu.open MenuMsg
    , isCampaign =
        gtw
            |> Tuple.second
            |> Servers.getType
            |> (==) Servers.DesktopCampaign
    , onLogout =
        Account.HandleLogout
            |> account
    , onSetGateway =
        Account.HandleSetGateway
            >> account
    , onSetEndpoint =
        Account.HandleSetEndpoint
            >> account
    , onSetContext =
        Account.HandleSetContext
            >> account
    , onSetBounce =
        Servers.HandleSetBounce
            >> server sCId
    , onReadAllAccountNotifications =
        AccountNotifications.HandleReadAll
            |> accountNotif
    , onReadAllServerNotifications =
        ServerNotifications.HandleReadAll
            |> serverNotif sCId
    , onSetActiveNIP =
        Servers.HandleSetActiveNIP
            >> server sCId
    , onNewPublicDownload =
        Processes.HandleStartPublicDownload
            >>>> processes gCId
    , onBankAccountLogin =
        Finances.HandleBankAccountLogin sCId
            >>> finances
    , onBankAccountTransfer =
        Finances.HandleBankAccountTransfer sCId
            >>> finances
    , onAccountToast =
        Toast.HandleAccount >> toast
    , onServerToast =
        Toast.HandleServers >>> toast
    , onPoliteCrash =
        Account.HandleLogoutAndCrash >> account
    , onNewTextFile =
        \cid stg -> Filesystem.HandleNewTextFile >>> filesystem cid stg
    , onNewDir =
        \cid stg -> Filesystem.HandleNewDir >>> filesystem cid stg
    , onMoveFile =
        \cid stg -> Filesystem.HandleMove >>> filesystem cid stg
    , onRenameFile =
        \cid stg -> Filesystem.HandleRename >>> filesystem cid stg
    , onDeleteFile =
        \cid stg -> Filesystem.HandleDelete >> filesystem cid stg
    , onUpdateLog =
        \cid -> Logs.HandleUpdateContent >>> logs cid
    , onEncryptLog =
        \cid -> Logs.HandleEncrypt >> logs cid
    , onHideLog =
        \cid -> Logs.HandleHide >> logs cid
    , onDeleteLog =
        \cid -> Logs.HandleDelete >> logs cid
    , onMotherboardUpdate =
        \cid -> Hardware.HandleMotherboardUpdate >> hardware cid
    , onPauseProcess =
        \cid -> Processes.HandlePause >> processes cid
    , onResumeProcess =
        \cid -> Processes.HandleResume >> processes cid
    , onRemoveProcess =
        \cid -> Processes.HandleRemove >> processes cid
    , onWebLogin =
        Web.Login >>>>> web
    , onFetchUrl =
        \cid nId nIp r ->
            web <| Web.FetchUrl nIp nId cid r
    , onNewBruteforceProcess =
        \cid -> Processes.HandleStartBruteforce >> processes cid
    , onReplyEmail =
        Emails.HandleReply >>> emails
    , onActionDone =
        \app context ->
            context
                |> MissionsActions.GoApp app
                |> Missions.HandleActionDone
                |> missions
    , onWebLogout =
        \cid -> Servers.HandleLogout |> server cid
    , accountId =
        game
            |> Game.getAccount
            |> Account.getId
    }


menuConfig : ContextMenu.Config
menuConfig =
    let
        defaultConfig =
            ContextMenu.defaultConfig
    in
        { defaultConfig
            | direction = ContextMenu.RightBottom
            , overflowX = ContextMenu.Mirror
            , overflowY = ContextMenu.Mirror
            , containerColor = Color.rgb 255 255 255
            , hoverColor = Color.rgb 238 238 238
            , invertText = False
            , cursor = ContextMenu.Arrow
            , rounded = False
        }



-- helpers


type alias ContextMenuMagic =
    ContextMenu (List (List ( ContextMenu.Item, Msg )))


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


bounces : Bounces.Msg -> Msg
bounces =
    Account.BouncesMsg >> account


servers : Servers.Msg -> Msg
servers =
    Game.ServersMsg >> game


server : CId -> Servers.ServerMsg -> Msg
server cid =
    Servers.ServerMsg cid >> servers


serverNotif : CId -> ServerNotifications.Msg -> Msg
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


bounceMan :
    SessionManager.WindowRef
    -> Context
    -> BounceManager.Msg
    -> Msg
bounceMan windowRef context =
    Apps.BounceManagerMsg >> app windowRef context


app :
    SessionManager.WindowRef
    -> Context
    -> Apps.Msg
    -> Msg
app windowRef context =
    SessionManager.AppMsg windowRef context >> sessionManager
