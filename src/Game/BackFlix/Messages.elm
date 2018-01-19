module Game.BackFlix.Messages exposing (..)

import Requests.Types exposing (ResponseType)
import Game.BackFlix.Models exposing (..)


type Msg
    = HandleCreate Log
    | DummyOp


type LogMsg
    = LogRequest LogRequestMsg


type RequestMsg
    = Retry ResponseType


type LogRequestMsg
    = NoOp ResponseType
