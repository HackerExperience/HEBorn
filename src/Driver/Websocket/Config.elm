module Driver.Websocket.Config exposing (..)

import Json.Decode exposing (Value)
import Core.Flags as Core
import Game.Bank.Shared exposing (..)
import Game.Servers.Shared exposing (CId)
import Driver.Websocket.Channels exposing (..)
import Driver.Websocket.Messages exposing (..)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , onConnected : msg
    , onDisconnected : msg
    , onJoinedAccount : Value -> msg
    , onJoinedServer : CId -> Value -> msg
    , onJoinedBank : String -> Value -> msg
    , onJoinBankFailed : String -> msg
    , onJoinFailedServer : CId -> msg
    , onLeft : Channel -> Maybe Value -> msg
    , onEvent : Channel -> Result String ( String, String, Value ) -> msg
    }
