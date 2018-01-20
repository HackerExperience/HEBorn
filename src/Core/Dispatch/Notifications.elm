module Core.Dispatch.Notifications exposing (..)

import Time exposing (Time)
import Game.Servers.Shared exposing (CId)
import Game.Account.Notifications.Shared as Account
import Game.Servers.Notifications.Shared as Servers


-- TODO: NotifyChat (Maybe Time) Content


{-| Messages related to the websocket driver.
-}
type Dispatch
    = NotifyServer CId Servers.Content
    | ReadAllServer CId
    | NotifyAccount Account.Content
    | ReadAllAccount
