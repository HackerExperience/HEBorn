module Core.Dispatch
    exposing
        ( Dispatch
        , Internal(..)
        , none
        , batch
        , push
        , yield
        , account
        , core
        , os
        , servers
        , server
        , filesystem
        , logs
        , processes
        , hardware
        , storyline
        , emails
        , missions
        , websocket
        , finances
        , database
        , logflix
        , notifications
        )

{-| Dispatch types and syntax sugar for dispatching things.

Dispatches are generic and defined by domain, so a PasswordAcquired dispatch
is able to affect the OS instead of just Account.

-}

import Core.Dispatch.Account as Account
import Core.Dispatch.Core as Core
import Core.Dispatch.OS as OS
import Core.Dispatch.Servers as Servers
import Core.Dispatch.Storyline as Storyline
import Core.Dispatch.Websocket as Websocket
import Core.Dispatch.Notifications as Notifications
import Game.Servers.Shared exposing (CId, StorageId)
import Core.Dispatch.LogStream as LogFlix


type Dispatch
    = Dispatch (List Internal)


type Internal
    = Account Account.Dispatch
    | Core Core.Dispatch
    | OS OS.Dispatch
    | Servers Servers.Dispatch
    | Storyline Storyline.Dispatch
    | Websocket Websocket.Dispatch
    | Notifications Notifications.Dispatch
    | LogFlix LogFlix.Dispatch


none : Dispatch
none =
    Dispatch []


batch : List Dispatch -> Dispatch
batch =
    List.concatMap (\(Dispatch list) -> list) >> Dispatch


push : Dispatch -> Dispatch -> Dispatch
push (Dispatch left) (Dispatch right) =
    Dispatch <| List.foldl (::) right left


yield : Dispatch -> List Internal
yield (Dispatch list) =
    list


account : Account.Dispatch -> Dispatch
account =
    Account >> dispatch


core : Core.Dispatch -> Dispatch
core =
    Core >> dispatch


os : OS.Dispatch -> Dispatch
os =
    OS >> dispatch


servers : Servers.Dispatch -> Dispatch
servers =
    Servers >> dispatch


server : CId -> Servers.Server -> Dispatch
server id =
    Servers.Server id >> Servers >> dispatch


filesystem : CId -> StorageId -> Servers.Filesystem -> Dispatch
filesystem cid id =
    Servers.Filesystem id >> server cid


logs : CId -> Servers.Logs -> Dispatch
logs id =
    Servers.Logs >> server id


processes : CId -> Servers.Processes -> Dispatch
processes id =
    Servers.Processes >> server id


hardware : CId -> Servers.Hardware -> Dispatch
hardware id =
    Servers.Hardware >> server id


storyline : Storyline.Dispatch -> Dispatch
storyline =
    Storyline >> dispatch


emails : Storyline.Emails -> Dispatch
emails =
    Storyline.Emails >> storyline


missions : Storyline.Missions -> Dispatch
missions =
    Storyline.Missions >> storyline


websocket : Websocket.Dispatch -> Dispatch
websocket =
    Websocket >> dispatch


notifications : Notifications.Dispatch -> Dispatch
notifications =
    Notifications >> dispatch


finances : Account.Finances -> Dispatch
finances =
    Account.Finances >> account


database : Account.Database -> Dispatch
database =
    Account.Database >> account


logflix : LogFlix.Dispatch -> Dispatch
logflix =
    LogFlix >> dispatch



-- internals


dispatch : Internal -> Dispatch
dispatch =
    List.singleton >> Dispatch
