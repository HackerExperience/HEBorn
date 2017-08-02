module Events.Events exposing (Event(..), handler)

import Driver.Websocket.Channels as Ws
import Driver.Websocket.Reports as Ws
import Events.Account as Account
import Json.Encode exposing (Value)


type Event
    = AccountEvent Account.Event
    | ServerEvent
    | RequestsEvent
    | Report Ws.Report


handler : Ws.Channel -> String -> Value -> Event
handler channel event value =
    case channel of
        Ws.AccountChannel ->
            AccountEvent <| Account.handler event value

        Ws.RequestsChannel ->
            RequestsEvent

        Ws.ServerChannel ->
            ServerEvent
