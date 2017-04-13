module Driver.Websocket.Messages exposing (Msg(..))

import Json.Decode


type Msg
    = UpdateSocketParams ( String, String )
    | JoinChannel ( String, String, String )
    | NewMsg Json.Decode.Value
