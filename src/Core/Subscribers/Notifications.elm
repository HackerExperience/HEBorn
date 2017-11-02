module Core.Subscribers.Notifications exposing (..)

import Core.Dispatch.Notifications exposing (..)
import Core.Subscribers.Helpers exposing (..)
import Game.Notifications.Messages as Notifications
import Game.Notifications.Source exposing (Source(..))
import Game.Servers.Messages as Servers
import Game.Account.Messages as Account


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        HandleInsert Nothing content ->
            [ toast content
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
