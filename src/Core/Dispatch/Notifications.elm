module Core.Dispatch.Notifications exposing (..)

import Time exposing (Time)
import Game.Notifications.Models exposing (Content)
import Game.Notifications.Source exposing (Source)


{-| Messages related to player's account.
-}
type Dispatch
    = HandleInsert (Maybe Data) Content
    | ReadAll Source


{-| source, creation time, is read
-}
type alias Data =
    ( Source, Time, Bool )
