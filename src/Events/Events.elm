module Events.Events exposing (Event(..), handler)

import Utils.Events exposing (Router)
import Driver.Websocket.Channels as Ws
import Driver.Websocket.Reports as Ws
import Events.Account as Account
import Events.Meta as Meta
import Events.Servers as Servers


type Event
    = AccountEvent Account.Event
    | ServersEvent Ws.Channel Servers.Event
    | MetaEvent Meta.Event
    | Report Ws.Report


handler : Ws.Channel -> Router Event
handler channel event json =
    case channel of
        Ws.RequestsChannel ->
            Nothing

        Ws.AccountChannel _ ->
            Account.handler event json
                |> Maybe.map AccountEvent

        Ws.ServerChannel _ ->
            Servers.handler event json
                |> Maybe.map (ServersEvent channel)
