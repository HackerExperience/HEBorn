module Game.Meta.Messages exposing (..)

import Events.Events as Events


type MetaMsg
    = ToDo
    | Event Events.Response
