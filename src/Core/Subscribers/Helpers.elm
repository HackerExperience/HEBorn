module Core.Subscribers.Helpers exposing (..)

import Apps.Messages as Apps
import Core.Messages as Core
import Driver.Websocket.Messages as Ws
import Setup.Messages as Setup
import OS.Messages as OS
import OS.SessionManager.Messages as SessionManager
import Game.Messages as Game
import Game.Account.Messages as Account
import Game.Account.Database.Messages as Database
import Game.Servers.Messages as Servers
import Game.Servers.Processes.Messages as Processes
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
server cid =
    Servers.ServerMsg cid >> servers


processes : CId -> Processes.Msg -> Core.Msg
processes cid =
    Servers.ProcessesMsg >> server cid


web : Web.Msg -> Core.Msg
web =
    Game.WebMsg >> game


story : Storyline.Msg -> Core.Msg
story =
    Game.StoryMsg >> game


missions : Missions.Msg -> Core.Msg
missions =
    Storyline.MissionsMsg >> story


emails : Emails.Msg -> Core.Msg
emails =
    Storyline.EmailsMsg >> story


apps : List Apps.Msg -> Core.Msg
apps =
    SessionManager.EveryAppMsg >> sessionManager


sessionManager : SessionManager.Msg -> Core.Msg
sessionManager =
    OS.SessionManagerMsg >> os


os : OS.Msg -> Core.Msg
os =
    Core.OSMsg
