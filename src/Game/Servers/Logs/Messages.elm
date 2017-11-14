module Game.Servers.Logs.Messages exposing (..)

import Requests.Types exposing (ResponseType)
import Game.Servers.Logs.Models exposing (..)


type Msg
    = HandleDelete ID
    | HandleHide ID
    | HandleCreated ID Log
    | LogMsg ID LogMsg
    | Request RequestMsg


type LogMsg
    = HandleUpdateContent String
    | HandleEncrypt
    | Decrypt String
    | LogRequest LogRequestMsg


type RequestMsg
    = IndexRequest ResponseType


type LogRequestMsg
    = NoOp ResponseType
