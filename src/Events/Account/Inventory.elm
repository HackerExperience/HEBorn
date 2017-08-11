module Events.Account.Inventory exposing (Event(..), handler, decoder)

import Json.Decode
    exposing
        ( Decoder
        , succeed
        , fail
        , decodeValue
        , andThen
        , dict
        , string
        , int
        )
import Json.Decode.Pipeline exposing (decode, required, optional)
import Dict
import Utils.Events exposing (Handler, commonError)
import Game.Account.Inventory.Models exposing (..)


type Event
    = Changed


handler : String -> Handler Event
handler event json =
    case event of
        "changed" ->
            onChanged json

        _ ->
            Nothing



-- internals


onChanged : Handler Event
onChanged json =
    Just Changed


decoder : Decoder Model
decoder =
    dict component


component : Decoder Component
component =
    decode componentAssembler
        |> required "type" componentType
        |> optional "clock" int 0
        |> optional "cores" int 0
        |> optional "size" int 0
        |> optional "slots" slots Dict.empty


slots : Decoder MOBOSlots
slots =
    dict slot


slot : Decoder MOBOSlot
slot =
    decode MOBOSlot
        |> required "internal" string
        |> required "type" componentType


componentType : Decoder ComponentType
componentType =
    let
        guesser str =
            case str of
                "ram" ->
                    succeed RAM

                "cpu" ->
                    succeed CPU

                "hdd" ->
                    succeed HDD

                "nic" ->
                    succeed NIC

                "mobo" ->
                    succeed MOBO

                error ->
                    fail <| commonError "mobo_slot_type" error
    in
        string |> andThen guesser


componentAssembler :
    ComponentType
    -> Int
    -> Int
    -> Int
    -> MOBOSlots
    -> Component
componentAssembler type_ clock cores size slots =
    case type_ of
        RAM ->
            ComponentRAM { size = size }

        CPU ->
            ComponentCPU { clock = clock, cores = cores }

        HDD ->
            ComponentHDD { size = size }

        NIC ->
            ComponentNIC {}

        MOBO ->
            ComponentMOBO { slots = slots }
