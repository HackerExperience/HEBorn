module Events.Events exposing (Event(..), handler)

import Utils.Events exposing (Router)
import Driver.Websocket.Channels as Ws
import Driver.Websocket.Reports as Ws
import Events.Account as Account
import Events.Meta as Meta
import Events.Servers as Servers


type Event
    = AccountEvent Account.Event
    | ServersEvent Servers.Event
    | MetaEvent Meta.Event
    | Report Ws.Report


handler : Ws.Channel -> Router Event
handler channel context event json =
    case channel of
        Ws.RequestsChannel ->
            Nothing

        Ws.AccountChannel ->
            Account.handler context event json
                |> Maybe.map AccountEvent

        Ws.ServerChannel ->
            Servers.handler context event json
                |> Maybe.map ServersEvent
