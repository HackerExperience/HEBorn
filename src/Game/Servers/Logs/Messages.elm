module Game.Servers.Logs.Messages exposing (..)

import Requests.Types exposing (ResponseType)
import Game.Servers.Logs.Models exposing (..)


type Msg
    = HandleCreated ID Log
    | HandleUpdateContent ID String
    | HandleHide ID
    | HandleEncrypt ID
    | HandleDecrypt ID String
    | HandleDelete ID
