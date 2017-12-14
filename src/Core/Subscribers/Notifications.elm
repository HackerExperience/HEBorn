module Core.Subscribers.Notifications exposing (dispatch)

import Game.Notifications.Messages as Notifications
import OS.Toasts.Messages as Toasts
import Core.Dispatch.Notifications exposing (..)
import Core.Subscribers.Helpers exposing (..)


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        NotifyServer a b c ->
            [ serverNotif a <| Notifications.HandleInsert b c ]

        ReadAllServer a ->
            [ serverNotif a <| Notifications.HandleReadAll ]

        NotifyAccount a b ->
            [ accountNotif <| Notifications.HandleInsert a b ]

        ReadAllAccount ->
            [ accountNotif <| Notifications.HandleReadAll ]

        Toast a b ->
            [ toasts <| Toasts.HandleInsert a b ]
