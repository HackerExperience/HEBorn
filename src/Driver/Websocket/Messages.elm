module Driver.Websocket.Messages exposing (Msg(..))

import Json.Decode


type alias RequestID =
    String


type Msg
    = UpdateSocketParams ( String, String )
    | JoinChannel ( String, String )
    | NewNotification Json.Decode.Value
