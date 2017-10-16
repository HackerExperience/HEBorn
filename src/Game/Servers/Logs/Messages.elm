module Game.Servers.Logs.Messages exposing (..)

import Requests.Types exposing (ResponseType)
import Game.Servers.Logs.Models exposing (..)


type Msg
    = Delete ID
    | Hide ID
    | LogMsg ID LogMsg
    | Request RequestMsg


type LogMsg
    = UpdateContent String
    | Encrypt
    | Decrypt String
    | LogRequest LogRequestMsg


type RequestMsg
    = IndexRequest ResponseType


type LogRequestMsg
    = NoOp ResponseType
