module Requests.Topics exposing (..)

import Driver.Websocket.Channels exposing (..)
import Requests.Types exposing (..)
import Game.Account.Models as Account
import Game.Servers.Shared as Servers
import Game.Network.Types exposing (NIP)


type Topic
    = WebsocketTopic Channel String
    | HttpTopic String


login : Topic
login =
    HttpTopic "account/login"


register : Topic
register =
    HttpTopic "account/register"


logout : Topic
logout =
    WebsocketTopic RequestsChannel "account.logout"


accountResync : Account.ID -> Topic
accountResync id =
    WebsocketTopic (AccountChannel id) "bootstrap"


serverResync : Servers.ID -> Topic
serverResync id =
    WebsocketTopic (ServerChannel id) "bootstrap"



-- logs


logsSync : Servers.ID -> Topic
logsSync nip =
    WebsocketTopic (ServerChannel nip) "log.index"



-- meta


metaSync : Servers.ID -> Topic
metaSync nip =
    WebsocketTopic (ServerChannel nip) "meta.index"



-- processes


processesSync : Servers.ID -> Topic
processesSync nip =
    WebsocketTopic (ServerChannel nip) "processes.index"



-- filesytem


fsSync : Servers.ID -> Topic
fsSync nip =
    WebsocketTopic (ServerChannel nip) "file.index"


fsDelete : Servers.ID -> Topic
fsDelete nip =
    WebsocketTopic (ServerChannel nip) "file.delete"


fsMove : Servers.ID -> Topic
fsMove nip =
    WebsocketTopic (ServerChannel nip) "file.move"


fsRename : Servers.ID -> Topic
fsRename nip =
    WebsocketTopic (ServerChannel nip) "file.rename"


fsCreate : Servers.ID -> Topic
fsCreate nip =
    WebsocketTopic (ServerChannel nip) "file.create"


fsDownload : Servers.ID -> Topic
fsDownload nip =
    WebsocketTopic (ServerChannel nip) "file.download"


fsPublicDownload : Servers.ID -> Topic
fsPublicDownload nip =
    -- CID NEEDS TO BE GATEWAY
    WebsocketTopic (ServerChannel nip) "public.download"



-- Player Actions


bruteforce : Servers.ID -> Topic
bruteforce nip =
    WebsocketTopic (ServerChannel nip) "bruteforce"


browse : Servers.ID -> Topic
browse nip =
    WebsocketTopic (ServerChannel nip) "browse"
