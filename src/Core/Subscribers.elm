module Core.Subscribers exposing (dispatch)

{-| Convert generic dispatches into domain specific messages.

This is what does the real dispatching.

-}

import Core.Dispatch as Dispatch exposing (Dispatch, Internal)
import Core.Subscribers.Helpers exposing (..)
import Core.Subscribers.Account as Account
import Core.Subscribers.Core as Core
import Core.Subscribers.Notifications as Notifications
import Core.Subscribers.OS as OS
import Core.Subscribers.Servers as Servers
import Core.Subscribers.Storyline as Storyline
import Core.Subscribers.Websocket as Websocket
import Core.Subscribers.BackFlix as BackFlix


dispatch : Dispatch -> Subscribers
dispatch =
    Dispatch.yield >> List.concatMap fromInternal



-- internals


fromInternal : Internal -> Subscribers
fromInternal dispatch =
    case dispatch of
        Dispatch.Account dispatch ->
            Account.dispatch dispatch

        Dispatch.Core dispatch ->
            Core.dispatch dispatch

        Dispatch.OS dispatch ->
            OS.dispatch dispatch

        Dispatch.Servers dispatch ->
            Servers.dispatch dispatch

        Dispatch.Storyline dispatch ->
            Storyline.dispatch dispatch

        Dispatch.Websocket dispatch ->
            Websocket.dispatch dispatch

        Dispatch.Notifications dispatch ->
            Notifications.dispatch dispatch

        Dispatch.BackFlix dispatch ->
            BackFlix.dispatch dispatch
