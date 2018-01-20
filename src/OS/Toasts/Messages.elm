module OS.Toasts.Messages exposing (Msg(..))

import Game.Servers.Shared exposing (CId)
import Game.Account.Notifications.Shared as AccountNotifications
import Game.Servers.Notifications.Shared as ServersNotifications


type Msg
    = Remove Int
    | Trash Int
    | Fade Int
    | HandleAccount AccountNotifications.Content
    | HandleServers CId ServersNotifications.Content
