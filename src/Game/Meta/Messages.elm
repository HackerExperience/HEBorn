module Game.Meta.Messages exposing (..)

import Events.Events as Events
import Time exposing (Time)


type MetaMsg
    = ToDo
    | Event Events.Response
    | Tick Time
