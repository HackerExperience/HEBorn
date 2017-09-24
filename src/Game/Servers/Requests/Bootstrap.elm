module Game.Servers.Requests.Bootstrap
    exposing
        ( Response(..)
        , Server(..)
        , ServerData
        , GatewayData
        , EndpointData
        , request
        , receive
        , decoder
        , gatewayDecoder
        , endpointDecoder
        , toServer
        )

import Json.Decode as Decode
    exposing
        ( Decoder
        , Value
        , decodeValue
        , list
        , string
        , float
        , value
        , maybe
        )
import Json.Decode.Pipeline exposing (decode, required, optional)
import Decoders.Notifications exposing (notificationsField)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..), emptyPayload)
import Game.Network.Types exposing (NIP)
import Game.Notifications.Models as Notifications
import Decoders.Network
import Game.Servers.Messages
    exposing
        ( Msg(Request)
        , RequestMsg(BootstrapRequest)
        )
import Game.Servers.Shared as Model
import Game.Servers.Models as Model
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Logs.Models as Logs
import Game.Servers.Models exposing (..)
import Game.Servers.Processes.Models as Processes
import Game.Servers.Tunnels.Models as Tunnels


type Response
    = Okay Server


type Server
    = GatewayServer GatewayData
    | EndpointServer EndpointData


type alias ServerData e =
    { e
        | id : String
        , name : String

        --, type_ : String
        , nips : List NIP
        , coordinates : Maybe Float
        , logs : Maybe Value
        , tunnels : Maybe Value
        , filesystem : Maybe Value
        , processes : Maybe Value
        , notifications : Notifications.Model
    }


type alias GatewayData =
    ServerData
        { endpoints : List String
        }


type alias EndpointData =
    ServerData
        { bounce : Maybe String
        }


request : Model.ID -> ConfigSource a -> Cmd Msg
request id =
    -- this request is mainly used to fetch invaded computers
    Requests.request Topics.serverBootstrap
        (BootstrapRequest >> Request)
        (Just id)
        emptyPayload


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            decodeValue decoder json
                |> Result.map Okay
                |> Requests.report

        _ ->
            Nothing


decoder : Decoder Server
decoder =
    Decode.oneOf
        [ Decode.map GatewayServer gatewayDecoder
        , Decode.map EndpointServer endpointDecoder
        ]


gatewayDecoder : Decoder GatewayData
gatewayDecoder =
    let
        constructor endpoints =
            { endpoints = endpoints
            }

        specializedDecoder =
            decode constructor
                |> required "endpoints" (list string)

        join server special =
            { id = server.id
            , name = server.name
            , nips = server.nips
            , coordinates = server.coordinates
            , logs = server.logs
            , tunnels = server.tunnels
            , filesystem = server.filesystem
            , processes = server.processes
            , endpoints = special.endpoints
            , notifications = server.notifications
            }
    in
        Decode.map2 join genericDecoder specializedDecoder


endpointDecoder : Decoder EndpointData
endpointDecoder =
    let
        constructor bounce =
            { bounce = bounce
            }

        specializedDecoder =
            decode constructor
                |> optional "bounce" (maybe string) Nothing

        join server special =
            { id = server.id
            , name = server.name
            , nips = server.nips
            , coordinates = server.coordinates
            , logs = server.logs
            , tunnels = server.tunnels
            , filesystem = server.filesystem
            , processes = server.processes
            , bounce = special.bounce
            , notifications = server.notifications
            }
    in
        Decode.map2 join genericDecoder specializedDecoder


toServer : Server -> Model.Server
toServer server =
    -- TODO: bootstrap others
    let
        tryBootstrap f init value =
            Maybe.withDefault init <| Maybe.map (flip f init) value

        initializeCommoms data =
            { type_ = Desktop
            , nip = toNip data.nips
            , filesystem = Filesystem.initialModel
            , logs = Logs.initialModel
            , processes = Processes.initialModel
            , tunnels = Tunnels.initialModel
            , notifications = data.notifications
            }

        toNip =
            List.head >> Maybe.withDefault ( "::", "invalid" )
    in
        case server of
            GatewayServer data ->
                let
                    common =
                        initializeCommoms data

                    ownership =
                        GatewayOwnership
                            { endpoint = Nothing
                            , endpoints = data.endpoints
                            }
                in
                    { name = data.id
                    , nips = data.nips
                    , ownership = ownership
                    , type_ = common.type_
                    , nip = common.nip
                    , coordinates = data.coordinates
                    , filesystem = common.filesystem
                    , logs = common.logs
                    , processes = common.processes
                    , tunnels = common.tunnels
                    , notifications = common.notifications
                    }

            EndpointServer data ->
                let
                    common =
                        initializeCommoms data

                    ownership =
                        EndpointOwnership
                            { bounce = data.bounce
                            , analyzed = Nothing
                            }
                in
                    { name = data.id
                    , nips = data.nips
                    , ownership = ownership
                    , type_ = common.type_
                    , nip = common.nip
                    , coordinates = data.coordinates
                    , filesystem = common.filesystem
                    , logs = common.logs
                    , processes = common.processes
                    , tunnels = common.tunnels
                    , notifications = common.notifications
                    }



-- internals


genericDecoder : Decoder (ServerData {})
genericDecoder =
    let
        constructor id name nips coords logs tunnels fs procs notfs =
            { id = id
            , name = name
            , nips = nips
            , coordinates = coords
            , logs = logs
            , tunnels = tunnels
            , filesystem = fs
            , processes = procs
            , notifications = notfs
            }
    in
        decode constructor
            |> required "id" string
            |> required "name" string
            |> required "nips" (list Decoders.Network.nip)
            |> optional "coordinates" (maybe float) Nothing
            |> optional "logs" (maybe value) Nothing
            |> optional "tunnels" (maybe value) Nothing
            |> optional "filesystem" (maybe value) Nothing
            |> optional "processes" (maybe value) Nothing
            |> notificationsField
