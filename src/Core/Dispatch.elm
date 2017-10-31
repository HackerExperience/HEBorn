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
        , servers_
        , server_
        , filesystem_
        , logs_
        , processes_
        , storyline
        , emails_
        , missions_
        , websocket
          -- to kill:
        , setup
        , game
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
        , serverNotification
        , accountNotification
        , openApp
        , apps
        , browser
        , toasts
        , politeCrash
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
import Game.Servers.Shared exposing (CId)


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



-- TODO: remove underlines after fixing conflicts


account : Account.Dispatch -> Dispatch
account =
    Account >> dispatch


core : Core.Dispatch -> Dispatch
core =
    Core >> dispatch


os : OS.Dispatch -> Dispatch
os =
    OS >> dispatch


servers_ : Servers.Dispatch -> Dispatch
servers_ =
    Servers >> dispatch


server_ : CId -> Servers.Server -> Dispatch
server_ id =
    Servers.Server id >> Servers >> dispatch


filesystem_ : CId -> Servers.Filesystem -> Dispatch
filesystem_ id =
    Servers.Filesystem >> server_ id


logs_ : CId -> Servers.Logs -> Dispatch
logs_ id =
    Servers.Logs >> server_ id


processes_ : CId -> Servers.Processes -> Dispatch
processes_ id =
    Servers.Processes >> server_ id


storyline : Storyline.Dispatch -> Dispatch
storyline =
    Storyline >> dispatch


emails_ : Storyline.Emails -> Dispatch
emails_ =
    Storyline.Emails >> storyline


missions_ : Storyline.Missions -> Dispatch
missions_ =
    Storyline.Missions >> storyline


websocket : Websocket.Dispatch -> Dispatch
websocket =
    Websocket >> dispatch



-- compatibility layer we should eventually kill


setup : a -> Dispatch
setup msg =
    dispatch NoOp


game : a -> Dispatch
game msg =
    dispatch NoOp


database : a -> Dispatch
database msg =
    dispatch NoOp


servers : a -> Dispatch
servers msg =
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


toasts : a -> Dispatch
toasts msg =
    dispatch NoOp


politeCrash : a -> b -> Dispatch
politeCrash code details =
    dispatch NoOp



-- internals


dispatch : Internal -> Dispatch
dispatch =
    List.singleton >> Dispatch
