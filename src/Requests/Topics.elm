module Requests.Topics exposing (..)

import Driver.Websocket.Channels exposing (..)
import Requests.Types exposing (..)
import Game.Account.Models as Account
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


accountBootstrap : Account.ID -> Topic
accountBootstrap id =
    WebsocketTopic (AccountChannel id) "bootstrap"


serverBootstrap : NIP -> Topic
serverBootstrap nip =
    WebsocketTopic (ServerChannel nip) "bootstrap"



-- account


accountSync : Account.ID -> Topic
accountSync id =
    WebsocketTopic (AccountChannel id) "account.sync"



-- logs


logsSync : NIP -> Topic
logsSync nip =
    WebsocketTopic (ServerChannel nip) "log.index"



-- meta


metaSync : NIP -> Topic
metaSync nip =
    WebsocketTopic (ServerChannel nip) "meta.index"



-- processes


processesSync : NIP -> Topic
processesSync nip =
    WebsocketTopic (ServerChannel nip) "processes.index"



-- filesytem


fsSync : NIP -> Topic
fsSync nip =
    WebsocketTopic (ServerChannel nip) "file.index"


fsDelete : NIP -> Topic
fsDelete nip =
    WebsocketTopic (ServerChannel nip) "file.delete"


fsMove : NIP -> Topic
fsMove nip =
    WebsocketTopic (ServerChannel nip) "file.move"


fsRename : NIP -> Topic
fsRename nip =
    WebsocketTopic (ServerChannel nip) "file.rename"


fsCreate : NIP -> Topic
fsCreate nip =
    WebsocketTopic (ServerChannel nip) "file.create"



-- Player Actions


bruteforce : NIP -> Topic
bruteforce nip =
    WebsocketTopic (ServerChannel nip) "bruteforce"


browse : NIP -> Topic
browse nip =
    WebsocketTopic (ServerChannel nip) "browse"
