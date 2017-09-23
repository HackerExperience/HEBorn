module Requests.Topics exposing (..)

import Driver.Websocket.Channels exposing (..)
import Requests.Types exposing (..)


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


accountBootstrap : Topic
accountBootstrap =
    WebsocketTopic AccountChannel "bootstrap"


serverBootstrap : Topic
serverBootstrap =
    WebsocketTopic AccountChannel "server.bootstrap"



-- account


accountSync : Topic
accountSync =
    WebsocketTopic AccountChannel "account.sync"



-- logs


logsSync : Topic
logsSync =
    WebsocketTopic ServerChannel "log.index"



-- meta


metaSync : Topic
metaSync =
    WebsocketTopic ServerChannel "meta.index"



-- processes


processesSync : Topic
processesSync =
    WebsocketTopic ServerChannel "processes.index"



-- filesytem


fsSync : Topic
fsSync =
    WebsocketTopic ServerChannel "file.index"


fsDelete : Topic
fsDelete =
    WebsocketTopic ServerChannel "file.delete"


fsMove : Topic
fsMove =
    WebsocketTopic ServerChannel "file.move"


fsRename : Topic
fsRename =
    WebsocketTopic ServerChannel "file.rename"


fsCreate : Topic
fsCreate =
    WebsocketTopic ServerChannel "file.create"



-- Player Actions


bruteforce : Topic
bruteforce =
    WebsocketTopic ServerChannel "bruteforce"


browse : Topic
browse =
    WebsocketTopic ServerChannel "network.browse"
