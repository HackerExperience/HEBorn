module Decoders.Hardware exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode
    exposing
        ( Decoder
        , succeed
        , fail
        , bool
        , float
        , string
        , dict
        , field
        , maybe
        , map
        , andThen
        )
import Json.Decode.Pipeline exposing (decode, required, custom)
import Utils.Json.Decode exposing (optionalMaybe, commonError)
import Game.Servers.Hardware.Models as Hardware exposing (..)
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Meta.Types.Network.Connections as NetConnections
import Decoders.Network
import Decoders.Components


hardware : Decoder Model
hardware =
    decode Model
        |> optionalMaybe "motherboard" motherboard


motherboard : Decoder Motherboard
motherboard =
    decode Motherboard
        |> required "motherboard_id" (map Just string)
        |> required "network_connections" ncs
        |> required "slots" slots


ncs : Decoder Motherboard.NetConnections
ncs =
    dict nc


nc : Decoder NetConnections.Id
nc =
    Decoders.Network.nip


slots : Decoder Motherboard.Slots
slots =
    dict slot


slot : Decoder Motherboard.Slot
slot =
    decode Motherboard.Slot
        |> required "type" Decoders.Components.type_
        |> optionalMaybe "component_id" string
