module Core.Dispatch.Notifications exposing (..)

import Time exposing (Time)
import Game.Servers.Shared exposing (CId)
import Game.Notifications.Source exposing (Source)
import Game.Notifications.Models exposing (Content)


-- TODO: NotifyChat (Maybe Time) Content


{-| Messages related to the websocket driver.
-}
type Dispatch
    = NotifyServer CId (Maybe Time) Content
    | ReadAllServer CId
    | NotifyAccount (Maybe Time) Content
    | ReadAllAccount
    | Toast (Maybe Source) Content
