module Game.Network.Messages exposing (NetworkMsg(..))

import Events.Events as Events


type NetworkMsg
    = ToDo
    | Event Events.Response
