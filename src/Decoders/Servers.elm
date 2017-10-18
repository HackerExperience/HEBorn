module Decoders.Servers exposing (..)

import Json.Decode as Decode
    exposing
        ( Decoder
        , Value
        , andThen
        , map
        , oneOf
        , succeed
        , fail
        , string
        , float
        , value
        , field
        , list
        )
import Json.Decode.Pipeline exposing (decode, required, optional, custom)
import Utils.Json.Decode exposing (optionalMaybe)
import Game.Servers.Models exposing (..)
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Logs.Models as Logs
import Game.Servers.Processes.Models as Processes
import Game.Servers.Tunnels.Models as Tunnels
import Game.Notifications.Models as Notifications
import Game.Servers.Shared exposing (..)
import Game.Network.Types as Network exposing (NIP)
import Decoders.Network
import Decoders.Processes
import Decoders.Logs
import Decoders.Notifications
import Decoders.Tunnels
import Decoders.Filesystem


server : Maybe ServerUid -> Decoder Server
server serverUid =
    decode Server
        |> required "name" string
        |> optional "server_type" serverType Desktop
        |> required "nips" (list Decoders.Network.nip)
        |> optionalMaybe "coordinates" float
        |> filesystem
        |> logs
        |> processes
        |> tunnels
        |> custom (ownership serverUid)
        |> notifications


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


ownership : Maybe ServerUid -> Decoder Ownership
ownership serverUid =
    case serverUid of
        Just serverUid ->
            map GatewayOwnership (gatewayOwnership serverUid)

        Nothing ->
            map EndpointOwnership endpointOwnership


gatewayOwnership : ServerUid -> Decoder GatewayData
gatewayOwnership serverUid =
    succeed <| GatewayData serverUid [] Nothing


endpointOwnership : Decoder EndpointData
endpointOwnership =
    decode EndpointData
        |> optionalMaybe "bounce" string
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


filesystem : Decoder (Filesystem.Filesystem -> a) -> Decoder a
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
