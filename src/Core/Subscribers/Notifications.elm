module Core.Subscribers.Notifications exposing (dispatch)

import Game.Account.Notifications.Messages as AccountNotifications
import Game.Servers.Notifications.Messages as ServersNotifications
import OS.Toasts.Messages as Toasts
import Core.Dispatch.Notifications exposing (..)
import Core.Subscribers.Helpers exposing (..)


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        NotifyServer a b ->
            --[ serverNotif a <| Notifications.HandleInsert b c ]
            []

        ReadAllServer a ->
            --[ serverNotif a <| Notifications.HandleReadAll ]
            []

        NotifyAccount a ->
            --[ accountNotif <| Notifications.HandleInsert a b ]
            []

        ReadAllAccount ->
            --[ accountNotif <| Notifications.HandleReadAll ]
            []
