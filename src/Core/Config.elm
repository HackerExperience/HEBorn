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
import Game.Account.Messages as Account
import Game.Account.Bounces.Messages as Bounces
import Game.Account.Database.Messages as Database
import Game.Account.Finances.Messages as Finances
import Game.Account.Notifications.Messages as AccountNotifications
import Game.BackFlix.Messages as BackFlix
import Game.Meta.Types.Context exposing (Context)
import Game.Meta.Types.Apps.Desktop exposing (Reference, Requester)
import Game.Servers.Messages as Servers
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Hardware.Messages as Hardware
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Shared as Servers exposing (CId)
import Game.Storyline.StepActions.Shared as StepActions
import Game.Storyline.Messages as Storyline
import Game.Web.Messages as Web
import OS.Config as OS
import OS.Messages as OS
import OS.WindowManager.Shared as WindowManager
import OS.WindowManager.Messages as WindowManager
import OS.Toasts.Messages as Toast
import Apps.Browser.Messages as Browser


landingConfig : Bool -> Flags -> Landing.Config Msg
landingConfig windowLoaded flags =
    { flags = flags
    , toMsg = LandingMsg
    , onLogin = HandleBoot
    , windowLoaded = windowLoaded
    }


websocketConfig : Flags -> Ws.Config Msg
websocketConfig flags =
    let
        onConnected =
            BatchMsg
                [ HandleConnected
                , account Account.HandleConnected
                ]

        onJoinedAccount value =
            BatchMsg
                [ game <| Game.HandleJoinedAccount value
                , setup <| Setup.HandleJoinedAccount value
                ]

        onJoinedServer cid value =
            servers <| Servers.HandleJoinedServer cid value

        onLeft _ _ =
            BatchMsg []
    in
        { flags = flags
        , toMsg = WebsocketMsg
        , onConnected = onConnected
        , onDisconnected = account <| Account.HandleDisconnected
        , onJoinedAccount = onJoinedAccount
        , onJoinedServer = onJoinedServer
        , onJoinFailedServer = Web.HandleJoinServerFailed >> web
        , onLeft = onLeft
        , onEvent = HandleEvent
        }


eventsConfig : Events.Config Msg
eventsConfig =
    let
        forAccount =
            let
                onServerPasswordAcquired data =
                    BatchMsg
                        [ database <| Database.HandlePasswordAcquired data
                        , browsers <| Browser.HandlePasswordAcquired data
                        ]

                onStoryStepProceeded =
                    Storyline.HandleStepProceeded >> storyline

                onStoryEmailSent data =
                    BatchMsg
                        [ storyline <| Storyline.HandleNewEmail data
                        , data.contactId
                            |> AccountNotifications.HandleNewEmail
                            |> accountNotif
                        ]

                onStoryEmailReplyUnlocked =
                    Storyline.HandleReplyUnlocked >> storyline

                onStoryEmailReplySent =
                    Storyline.HandleReplySent >> storyline

                onBankAccountUpdated =
                    uncurry Finances.HandleBankAccountUpdated >> finances

                onBankAccountClosed =
                    Finances.HandleBankAccountClosed >> finances

                onDbAccountUpdated =
                    uncurry Database.HandleDatabaseAccountUpdated >> database

                onDbAccountRemoved =
                    Database.HandleDatabaseAccountRemoved >> database

                onVirusCollected =
                    Database.HandleCollectedVirus >> database

                onTutorialFinished =
                    .completed >> Account.HandleTutorialCompleted >> account
            in
                { onServerPasswordAcquired = onServerPasswordAcquired
                , onStoryStepProceeded = onStoryStepProceeded
                , onStoryEmailSent = onStoryEmailSent
                , onStoryEmailReplyUnlocked = onStoryEmailReplyUnlocked
                , onStoryEmailReplySent = onStoryEmailReplySent
                , onBankAccountUpdated = onBankAccountUpdated
                , onBankAccountClosed = onBankAccountClosed
                , onDbAccountUpdated = onDbAccountUpdated
                , onDbAccountRemoved = onDbAccountRemoved
                , onTutorialFinished = onTutorialFinished
                , onBounceCreated = uncurry Bounces.HandleCreated >> bounces
                , onBounceUpdated = uncurry Bounces.HandleUpdated >> bounces
                , onBounceRemoved = Bounces.HandleRemoved >> bounces
                , onVirusCollected = onVirusCollected
                }

        forBackFlix =
            { onNewLog = BackFlix.HandleCreate >> backflix }

        forServer =
            let
                onFileAdded cid ( id, data ) =
                    filesystem cid id <| uncurry Filesystem.HandleAdded data

                onFileDownloaded cid ( id, data ) =
                    BatchMsg []

                onProcessCreated cid data =
                    processes cid <| Processes.HandleProcessStarted data

                onProcessCompleted cid data =
                    processes cid <| Processes.HandleProcessConclusion data

                onProcessesRecalcado cid data =
                    processes cid <| Processes.HandleProcessesChanged data

                onBruteforceFailed cid data =
                    processes cid <| Processes.HandleBruteforceFailed data

                onLogCreated cid data =
                    logs cid <| uncurry Logs.HandleCreated data

                onMotherboardUpdated cid data =
                    hardware cid <| Hardware.HandleMotherboardUpdated data
            in
                { onFileAdded = onFileAdded
                , onFileDownloaded = onFileDownloaded
                , onProcessCreated = onProcessCreated
                , onProcessCompleted = onProcessCompleted
                , onProcessesRecalcado = onProcessesRecalcado
                , onBruteforceFailed = onBruteforceFailed
                , onLogCreated = onLogCreated
                , onMotherboardUpdated = onMotherboardUpdated
                }
    in
        { forAccount = forAccount
        , forBackFlix = forBackFlix
        , forServer = forServer
        }


gameConfig : Game.Config Msg
gameConfig =
    let
        onJoinServer =
            \cid payload ->
                ws <| Ws.HandleJoin (ServerChannel cid) payload

        onConnected =
            \accountId ->
                BatchMsg
                    [ ws <| Ws.HandleJoin (AccountChannel accountId) Nothing
                    , ws <| Ws.HandleJoin BackFlixChannel Nothing
                    ]
    in
        { toMsg = GameMsg
        , batchMsg = BatchMsg
        , onJoinServer = onJoinServer
        , onError = HandleCrash
        , onJoinFailed = browserTab Browser.HandleLoginFailed
        , onNewGateway = Setup.HandleJoinedServer >> setup
        , onConnected = onConnected
        , onDisconnected = HandleShutdown
        , onAccountToast = Toast.HandleAccount >> toast
        , onServerToast = Toast.HandleServers >>> toast
        , onBALoginSuccess = Browser.HandleBankLogin >> browserTab
        , onBALoginFailed = browserTab Browser.HandleBankLoginError
        , onBATransferSuccess = browserTab Browser.HandleBankTransfer
        , onBATransferFailed = browserTab Browser.HandleBankTransferError
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
    -> Context
    -> ( CId, Server )
    -> ( CId, Server )
    -> OS.Config Msg
osConfig game menu ctx (( sCId, _ ) as srv) (( gCId, gSrv ) as gtw) =
    let
        onActionDone =
            \desktopApp context ->
                context
                    |> StepActions.GoApp desktopApp
                    |> Storyline.HandleActionDone
                    |> storyline
    in
        { flags = Game.getFlags game
        , toMsg = OSMsg
        , batchMsg = BatchMsg
        , gameMsg = GameMsg
        , game = game
        , activeContext = ctx
        , activeServer = srv
        , activeGateway = gtw
        , onActionDone = onActionDone
        , menuView = ContextMenu.view menuConfig MenuMsg identity menu
        , menuAttr = ContextMenu.open MenuMsg
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


finances : Finances.Msg -> Msg
finances =
    Account.FinancesMsg >> account


os : OS.Msg -> Msg
os =
    OSMsg


toast : Toast.Msg -> Msg
toast =
    OS.ToastsMsg >> os


windowManager : WindowManager.Msg -> Msg
windowManager =
    OS.WindowManagerMsg >> os


app : WindowManager.AppId -> WindowManager.AppMsg -> Msg
app appId =
    WindowManager.AppMsg appId >> windowManager


apps : WindowManager.AppMsg -> Msg
apps =
    WindowManager.AppsMsg >> windowManager


browser : WindowManager.AppId -> Browser.Msg -> Msg
browser appId =
    WindowManager.BrowserMsg >> app appId


browserTab : Browser.TabMsg -> Requester -> Msg
browserTab msg { reference, browserTab } =
    msg
        |> Browser.SomeTabMsg browserTab
        |> browser reference


browsers : Browser.Msg -> Msg
browsers =
    WindowManager.BrowserMsg >> apps
