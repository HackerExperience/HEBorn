module Core.Subscribers.Notifications exposing (..)

import Time exposing (Time)
import Core.Messages as Core
import Core.Dispatch.Notifications exposing (..)
import Core.Subscribers.Helpers exposing (..)
import Game.Notifications.Source exposing (Source(..))
import Game.Notifications.Messages as Notifications
import Game.Notifications.Models exposing (Notification, Content)
import Game.Servers.Messages as Servers
import Game.Servers.Shared exposing (CId)
import Game.Account.Messages as Account
import OS.Messages as OS
import OS.Toasts.Models exposing (Toast, State(..))
import OS.Toasts.Messages as Toasts


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        HandleInsert Nothing content ->
            [ toastOnly content
            ]

        HandleInsert (Just ( Server cid, time, isRead )) content ->
            notifyServer cid time isRead content

        HandleInsert (Just ( Account, time, isRead )) content ->
            notifyAccount time isRead content

        HandleInsert (Just ( Chat, time, isRead )) content ->
            []

        ReadAll (Server cid) ->
            [ server cid <|
                Servers.NotificationsMsg <|
                    Notifications.ReadAll
            ]

        ReadAll Account ->
            [ account <|
                Account.NotificationsMsg <|
                    Notifications.ReadAll
            ]

        ReadAll Chat ->
            []


toastOnly : Content -> Core.Msg
toastOnly content =
    os <|
        OS.ToastsMsg <|
            Toasts.Insert <|
                Toast content Nothing Alive


notifyServer :
    CId
    -> Time
    -> Bool
    -> Content
    -> Subscribers
notifyServer cid time isRead content =
    [ Notification content isRead
        |> Notifications.Insert time
        |> Servers.NotificationsMsg
        |> server cid
    , os <|
        OS.ToastsMsg <|
            Toasts.Insert <|
                Toast content (Just (Server cid)) Alive
    ]


notifyAccount :
    Time
    -> Bool
    -> Content
    -> Subscribers
notifyAccount time isRead content =
    [ Notification content isRead
        |> Notifications.Insert time
        |> Account.NotificationsMsg
        |> account
    , os <|
        OS.ToastsMsg <|
            Toasts.Insert <|
                Toast content (Just Account) Alive
    ]
