module Core.Subscribers.Helpers exposing (..)

import Time exposing (Time)
import Apps.Messages as Apps
import Core.Messages as Core
import Driver.Websocket.Messages as Ws
import Setup.Messages as Setup
import OS.Messages as OS
import OS.SessionManager.Messages as SessionManager
import OS.Toasts.Models as Toasts exposing (Toast)
import OS.Toasts.Messages as Toasts
import Game.Messages as Game
import Game.Account.Messages as Account
import Game.BackFeed.Messages as BackFeed
import Game.Account.Database.Messages as Database
import Game.Notifications.Messages as Notifications
import Game.Notifications.Models as Notifications exposing (Notification)
import Game.Notifications.Source as Notifications
import Game.Servers.Messages as Servers
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Logs.Messages as Logs
import Game.Storyline.Messages as Storyline
import Game.Storyline.Missions.Messages as Missions
import Game.Storyline.Emails.Messages as Emails
import Game.Servers.Shared exposing (CId)
import Game.Web.Messages as Web


type alias Subscribers =
    List Core.Msg


ws : Ws.Msg -> Core.Msg
ws =
    Core.WebsocketMsg


setup : Setup.Msg -> Core.Msg
setup =
    Core.SetupMsg


game : Game.Msg -> Core.Msg
game =
    Core.GameMsg


account : Account.Msg -> Core.Msg
account =
    Game.AccountMsg >> game


database : Database.Msg -> Core.Msg
database =
    Account.DatabaseMsg >> account


servers : Servers.Msg -> Core.Msg
servers =
    Game.ServersMsg >> game


server : CId -> Servers.ServerMsg -> Core.Msg
server id =
    Servers.ServerMsg id >> servers


filesystem : CId -> Filesystem.Msg -> Core.Msg
filesystem id =
    Servers.FilesystemMsg >> server id


processes : CId -> Processes.Msg -> Core.Msg
processes id =
    Servers.ProcessesMsg >> server id


logs : CId -> Logs.Msg -> Core.Msg
logs id =
    Servers.LogsMsg >> server id


web : Web.Msg -> Core.Msg
web =
    Game.WebMsg >> game


storyline : Storyline.Msg -> Core.Msg
storyline =
    Game.StoryMsg >> game


missions : Missions.Msg -> Core.Msg
missions =
    Storyline.MissionsMsg >> storyline


emails : Emails.Msg -> Core.Msg
emails =
    Storyline.EmailsMsg >> storyline


apps : List Apps.Msg -> Core.Msg
apps =
    SessionManager.EveryAppMsg >> sessionManager


sessionManager : SessionManager.Msg -> Core.Msg
sessionManager =
    OS.SessionManagerMsg >> os


backfeed : BackFeed.Msg -> Core.Msg
backfeed =
    Game.LogFlixMsg >> game


os : OS.Msg -> Core.Msg
os =
    Core.OSMsg


toast : Notifications.Content -> Core.Msg
toast content =
    os <|
        OS.ToastsMsg <|
            Toasts.Insert <|
                Toast content Nothing Toasts.Alive


browser windowRef context =
    Apps.BrowserMsg
        >> app windowRef context


app windowRef context =
    SessionManager.AppMsg windowRef context
        >> sessionManager


notifyServer :
    CId
    -> Time
    -> Bool
    -> Notifications.Content
    -> Subscribers
notifyServer cid time isRead content =
    [ Notification content isRead
        |> Notifications.Insert time
        |> Servers.NotificationsMsg
        |> server cid
    , os <|
        OS.ToastsMsg <|
            Toasts.Insert <|
                Toast content
                    (Just (Notifications.Server cid))
                    Toasts.Alive
    ]


notifyAccount :
    Time
    -> Bool
    -> Notifications.Content
    -> Subscribers
notifyAccount time isRead content =
    [ Notification content isRead
        |> Notifications.Insert time
        |> Account.NotificationsMsg
        |> account
    , os <|
        OS.ToastsMsg <|
            Toasts.Insert <|
                Toast content
                    (Just Notifications.Account)
                    Toasts.Alive
    ]
