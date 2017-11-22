module Decoders.Components exposing (..)

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
        , andThen
        )
import Json.Decode.Pipeline exposing (decode, required, custom)
import Utils.Json.Decode exposing (commonError)
import Game.Meta.Types.Components exposing (..)
import Game.Meta.Types.Components.Type exposing (Type(..))
import Game.Meta.Types.Components.Specs as Specs exposing (Spec, Specs)


components : Specs -> Decoder Components
components specs =
    -- todo: decide if comp_id or dict
    dict <| component specs


component : Specs -> Decoder Component
component specs_ =
    decode Component
        |> required "name" string
        |> required "description" string
        |> required "durability" float
        |> required "used?" bool
        |> custom (specs specs_)


specs : Specs -> Decoder Spec
specs =
    let
        decoder specs id =
            case Dict.get id specs of
                Just spec ->
                    succeed spec

                Nothing ->
                    fail <| commonError "spec" id
    in
        decoder >> flip andThen (field "spec_id" string)


type_ : Decoder Type
type_ =
    let
        decoder t =
            case t of
                "cpu" ->
                    succeed CPU

                "hdd" ->
                    succeed HDD

                "ram" ->
                    succeed RAM

                "nic" ->
                    succeed NIC

                "usb" ->
                    succeed USB

                "motherboard" ->
                    succeed MOB

                _ ->
                    fail <| commonError "type" t
    in
        andThen decoder string
