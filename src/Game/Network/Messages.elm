module Game.Network.Messages exposing (Msg(..))

import Events.Events as Events


type Msg
    = ToDo
    | Event Events.Response
