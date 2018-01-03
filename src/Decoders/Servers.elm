module Decoders.Servers exposing (..)

import Json.Decode as Decode
    exposing
        ( Decoder
        , Value
        , andThen
        , map
        , map2
        , oneOf
        , succeed
        , fail
        , string
        , float
        , value
        , field
        , list
        , dict
        )
import Json.Decode.Pipeline
    exposing
        ( decode
        , hardcoded
        , required
        , optional
        , custom
        )
import Utils.Json.Decode exposing (optionalMaybe)
import Game.Servers.Models exposing (..)
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Logs.Models as Logs
import Game.Servers.Processes.Models as Processes
import Game.Servers.Tunnels.Models as Tunnels
import Game.Servers.Hardware.Models as Hardware
import Game.Notifications.Models as Notifications
import Game.Servers.Shared exposing (..)
import Decoders.Network
import Decoders.Processes
import Decoders.Logs
import Decoders.Notifications
import Decoders.Tunnels
import Decoders.Filesystem
import Decoders.Hardware


server : Maybe GatewayCache -> Decoder Server
server gatewayCache =
    decode Server
        |> optional "name" string ""
        |> optional "server_type" serverType Desktop
        |> required "mode" serverMode
        |> required "nips" (list Decoders.Network.nipTuple)
        |> optionalMaybe "coordinates" float
        |> required "main_storage" string
        |> required "storages" storages
        |> logs
        |> processes
        |> tunnels
        |> custom (ownership gatewayCache)
        |> notifications
        |> hardware


serverType : Decoder ServerType
serverType =
    let
        decodeType str =
            case str of
                "Desktop" ->
                    succeed Desktop

                "Mobile" ->
                    succeed Mobile

                str ->
                    fail ("Unknown server type `" ++ str ++ "'")
    in
        andThen decodeType string


ownership : Maybe GatewayCache -> Decoder Ownership
ownership gatewayCache =
    case gatewayCache of
        Just gatewayCache ->
            map GatewayOwnership (gatewayOwnership gatewayCache)

        Nothing ->
            map EndpointOwnership endpointOwnership


gatewayOwnership : GatewayCache -> Decoder GatewayData
gatewayOwnership { activeNIP, endpoints } =
    succeed <| GatewayData activeNIP endpoints Nothing


hardware : Decoder (Hardware.Model -> a) -> Decoder a
hardware =
    let
        default =
            Hardware.initialModel
    in
        required "hardware" Decoders.Hardware.hardware


endpointOwnership : Decoder EndpointData
endpointOwnership =
    decode EndpointData
        |> hardcoded Nothing
        |> optionalMaybe "analyzed" analyzedEndpoint


analyzedEndpoint : Decoder AnalyzedEndpoint
analyzedEndpoint =
    succeed {}


processes : Decoder (Processes.Model -> a) -> Decoder a
processes =
    let
        default =
            Processes.initialModel
    in
        optional "processes" (Decoders.Processes.model <| Just default) default


withStorageId : Decoder a -> Decoder ( StorageId, a )
withStorageId a =
    map2 (,) storageId a


storageId : Decoder StorageId
storageId =
    field "storage_id" string


storages : Decoder Storages
storages =
    dict storage


storage : Decoder Storage
storage =
    decode Storage
        |> required "name" string
        |> filesystem


filesystem : Decoder (Filesystem.Model -> a) -> Decoder a
filesystem =
    let
        default =
            Filesystem.initialModel
    in
        optional "filesystem"
            (Decoders.Filesystem.model <| Just default)
            default


logs : Decoder (Logs.Model -> a) -> Decoder a
logs =
    let
        default =
            Logs.initialModel
    in
        optional "logs" Decoders.Logs.model default


tunnels : Decoder (Tunnels.Model -> a) -> Decoder a
tunnels =
    let
        default =
            Tunnels.initialModel
    in
        optional "tunnels" Decoders.Tunnels.model default


notifications : Decoder (Notifications.Model -> a) -> Decoder a
notifications =
    let
        default =
            Notifications.initialModel
    in
        optional "notifications" Decoders.Notifications.model default


cids : Decoder (List CId)
cids =
    list cid


cid : Decoder CId
cid =
    oneOf [ playerCId, remoteCId ]


playerCId : Decoder CId
playerCId =
    map GatewayCId <| field "server_id" string


remoteCId : Decoder CId
remoteCId =
    map EndpointCId <| Decoders.Network.nip


serverMode : Decoder ServerMode
serverMode =
    let
        decodeType str =
            case str of
                "campaign" ->
                    succeed Campaign

                "freemode" ->
                    succeed Freemode

                str ->
                    fail ("Unknown server mode `" ++ str ++ "'")
    in
        andThen decodeType string
