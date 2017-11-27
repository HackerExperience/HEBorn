module Game.BackFeed.Messages exposing (..)

import Requests.Types exposing (ResponseType)
import Game.BackFeed.Models exposing (..)


type Msg
    = HandleCreate BackLog
    | DummyOp


type BackLogMsg
    = BackLogRequest BackLogRequestMsg


type RequestMsg
    = Retry ResponseType


type BackLogRequestMsg
    = NoOp ResponseType
