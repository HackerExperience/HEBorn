module Core.Dispatch
    exposing
        ( Dispatch
        , Internal(..)
        , none
        , batch
        , push
        , yield
          -- to kill:
        , core
        , setup
        , websocket
        , game
        , os
        , account
        , database
        , servers
        , web
        , mission
        , missionAction
        , email
        , story
        , server
        , filesystem
        , processes
        , logs
        , log
        , tunnels
        , serverNotification
        , accountNotification
        , meta
        , openApp
        , apps
        , appsOfSession
        , browser
        , toasts
        , politeCrash
        )

import Core.Dispatch.Account as Account
import Core.Dispatch.Core as Core
import Core.Dispatch.OS as OS
import Core.Dispatch.Servers as Servers
import Core.Dispatch.Storyline as Storyline
import Core.Dispatch.Websocket as Websocket


type Dispatch
    = Dispatch (List Internal)


type Internal
    = Account Account.Dispatch
    | Core Core.Dispatch
    | OS OS.Dispatch
    | Servers Servers.Dispatch
    | Storyline Storyline.Dispatch
    | Websocket Websocket.Dispatch
    | NoOp


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



-- dispatchables


accountD : Account.Dispatch -> Dispatch
accountD =
    Account >> dispatch


coreD : Core.Dispatch -> Dispatch
coreD =
    Core >> dispatch


osD : OS.Dispatch -> Dispatch
osD =
    OS >> dispatch


serversD : Servers.Dispatch -> Dispatch
serversD =
    Servers >> dispatch


storylineD : Storyline.Dispatch -> Dispatch
storylineD =
    Storyline >> dispatch


websocketD : Websocket.Dispatch -> Dispatch
websocketD =
    Websocket >> dispatch



-- dispatchables we should kill


websocket : a -> Dispatch
websocket msg =
    dispatch NoOp


setup : a -> Dispatch
setup msg =
    dispatch NoOp


game : a -> Dispatch
game msg =
    dispatch NoOp


core : a -> Dispatch
core msg =
    dispatch NoOp


account : a -> Dispatch
account msg =
    dispatch NoOp


database : a -> Dispatch
database msg =
    dispatch NoOp


servers : a -> Dispatch
servers msg =
    dispatch NoOp


meta : a -> Dispatch
meta msg =
    dispatch NoOp


story : a -> Dispatch
story msg =
    dispatch NoOp


mission : a -> Dispatch
mission msg =
    dispatch NoOp


email : a -> Dispatch
email msg =
    dispatch NoOp


missionAction : a -> b -> Dispatch
missionAction data act =
    dispatch NoOp


server : a -> b -> Dispatch
server cid msg =
    dispatch NoOp


filesystem : a -> b -> Dispatch
filesystem cid msg =
    dispatch NoOp


processes : a -> b -> Dispatch
processes cid msg =
    dispatch NoOp


logs : a -> b -> Dispatch
logs cid msg =
    dispatch NoOp


log : a -> b -> c -> Dispatch
log serverId cid msg =
    dispatch NoOp


tunnels : a -> b -> Dispatch
tunnels cid msg =
    dispatch NoOp


serverNotification : a -> b -> Dispatch
serverNotification cid msg =
    dispatch NoOp


accountNotification : a -> Dispatch
accountNotification msg =
    dispatch NoOp


web : a -> Dispatch
web msg =
    dispatch NoOp


browser : a -> b -> c -> Dispatch
browser windowRef context msg =
    dispatch NoOp


openApp : a -> b -> Dispatch
openApp context app =
    dispatch NoOp


apps : a -> Dispatch
apps msgs =
    dispatch NoOp


appsOfSession : a -> b -> c -> Dispatch
appsOfSession cid context msgs =
    dispatch NoOp



-- internals


dispatch : Internal -> Dispatch
dispatch =
    List.singleton >> Dispatch



-- internals we must kill


os : a -> Dispatch
os msg =
    dispatch NoOp


sessionManager : a -> Dispatch
sessionManager msg =
    dispatch NoOp


toasts : a -> Dispatch
toasts msg =
    dispatch NoOp


app : a -> b -> c -> Dispatch
app windowRef context msg =
    dispatch NoOp


politeCrash : a -> b -> Dispatch
politeCrash code details =
    dispatch NoOp
