module Game.Notifications.Messages exposing (..)

import Time exposing (Time)
import Game.Notifications.Models exposing (..)


type Msg
    = ReadAll
    | Insert Time Notification
