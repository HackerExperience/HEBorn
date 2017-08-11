module Events.Servers exposing (Event(..), handler)

import Utils.Events exposing (Router, Handler, parse)
import Events.Servers.Filesystem as Filesystem
import Events.Servers.Hardware as Hardware
import Events.Servers.Logs as Logs
import Events.Servers.Processes as Processes
import Events.Servers.Tunnels as Tunnels


type Event
    = ServerEvent String ServerEvent


type ServerEvent
    = Changed
    | FilesystemEvent Filesystem.Event
    | HardwareEvent Hardware.Event
    | LogsEvent Logs.Event
    | ProcessesEvent Processes.Event
    | TunnelsEvent Tunnels.Event


handler : Router Event
handler context event json =
    case context of
        Just id ->
            Maybe.map (ServerEvent id) <| handleServer event json

        Nothing ->
            Nothing



-- internals


handleServer : String -> Handler ServerEvent
handleServer event json =
    case parse event of
        ( Just "filesystem", event ) ->
            Maybe.map FilesystemEvent <| Filesystem.handler event json

        ( Just "hardware", event ) ->
            Maybe.map HardwareEvent <| Hardware.handler event json

        ( Just "log", event ) ->
            Maybe.map LogsEvent <| Logs.handler event json

        ( Just "processes", event ) ->
            Maybe.map ProcessesEvent <| Processes.handler event json

        ( Just "tunnels", event ) ->
            Maybe.map TunnelsEvent <| Tunnels.handler event json

        ( Just "server", "changed" ) ->
            onChanged json

        _ ->
            Nothing


onChanged : Handler ServerEvent
onChanged json =
    Just Changed
