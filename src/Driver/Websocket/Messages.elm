module Driver.Websocket.Messages exposing (..)

import Driver.Websocket.Channels exposing (..)
import Game.Account.Finances.Models exposing (AccountId)
import Json.Decode exposing (Value)


type alias Token =
    String


type alias ClientName =
    String


type Msg
    = Connected Token ClientName
    | Disconnected
    | Joined Channel Value
    | JoinFailed Channel Value
    | Left Channel Value
    | HandleJoin Channel (Maybe Value)
    | HandleLeave Channel
