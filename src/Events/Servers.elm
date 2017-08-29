module Events.Servers
    exposing
        ( Event(..)
        , ServerEvent(..)
        , Server
        , ID
        , Name
        , Coordinates
        , handler
        , decoder
        )

import Json.Decode exposing (Decoder, decodeValue, list, string, float)
import Json.Decode.Pipeline exposing (decode, required)
import Utils.Events exposing (Router, Handler, parse, notify)
import Events.Servers.Filesystem as Filesystem
import Events.Servers.Hardware as Hardware
import Events.Servers.Logs as Logs
import Events.Servers.Processes as Processes
import Events.Servers.Tunnels as Tunnels
import Game.Network.Types exposing (NIP, decodeNip)


-- server changed events doesn't include the full server


type alias Server =
    { id : ID
    , name : Name
    , coordinates : Coordinates
    , nip : NIP
    , nips : List NIP
    }


type alias ID =
    String


type alias Name =
    String


type alias Coordinates =
    Float


type Event
    = ServerEvent String ServerEvent


type ServerEvent
    = Changed Server
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


decoder : Decoder Server
decoder =
    -- this will only handle local server informations
    decode Server
        |> required "id" string
        |> required "name" string
        |> required "coordinates" float
        |> required "nip" decodeNip
        |> required "nips" (list decodeNip)



-- internals


handleServer : String -> Handler ServerEvent
handleServer event json =
    case parse event of
        ( Just "filesystem", event ) ->
            Maybe.map FilesystemEvent <| Filesystem.handler event json

        ( Just "hardware", event ) ->
            Maybe.map HardwareEvent <| Hardware.handler event json

        ( Just "logs", event ) ->
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
    decodeValue decoder json
        |> Result.map Changed
        |> notify
