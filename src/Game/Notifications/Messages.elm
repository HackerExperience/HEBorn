module Game.Notifications.Messages exposing (..)

import Time exposing (Time)
import Game.Notifications.Models exposing (..)


type Msg
    = HandleInsert (Maybe Time) Content
    | HandleReadAll
