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
        , storyline
        , emails
        , missions_
        , websocket
        , notifications
          -- to kill:
        , web
        , mission
        , missionAction
        , serverNotification
        , accountNotification
        , openApp
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
import Core.Dispatch.Notifications as Notifications
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
    | Notifications Notifications.Dispatch
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


servers : Servers.Dispatch -> Dispatch
servers =
    Servers >> dispatch


server : CId -> Servers.Server -> Dispatch
server id =
    Servers.Server id >> Servers >> dispatch


filesystem : CId -> Servers.Filesystem -> Dispatch
filesystem id =
    Servers.Filesystem >> server id


logs : CId -> Servers.Logs -> Dispatch
logs id =
    Servers.Logs >> server id


processes : CId -> Servers.Processes -> Dispatch
processes id =
    Servers.Processes >> server id


storyline : Storyline.Dispatch -> Dispatch
storyline =
    Storyline >> dispatch


emails : Storyline.Emails -> Dispatch
emails =
    Storyline.Emails >> storyline


missions_ : Storyline.Missions -> Dispatch
missions_ =
    Storyline.Missions >> storyline


websocket : Websocket.Dispatch -> Dispatch
websocket =
    Websocket >> dispatch


notifications : Notifications.Dispatch -> Dispatch
notifications =
    Notifications >> dispatch



-- compatibility layer we should eventually kill


game : a -> Dispatch
game msg =
    dispatch NoOp


mission : a -> Dispatch
mission msg =
    dispatch NoOp


missionAction : a -> b -> Dispatch
missionAction data act =
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
