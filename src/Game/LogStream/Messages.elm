module Game.LogStream.Messages exposing (..)

import Requests.Types exposing (ResponseType)
import Game.LogStream.Models exposing (..)


type Msg
    = HandleCreate Log
    | DummyOp


type LogMsg
    = LogRequest LogRequestMsg


type RequestMsg
    = Retry ResponseType


type LogRequestMsg
    = NoOp ResponseType
