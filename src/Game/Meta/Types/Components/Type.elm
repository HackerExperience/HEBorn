module Game.Meta.Types.Components.Type exposing (..)


type Type
    = CPU
    | HDD
    | RAM
    | NIC
    | USB
    | MOB


typeToString : Type -> String
typeToString type_ =
    case type_ of
        CPU ->
            "CPU"

        HDD ->
            "HDD"

        RAM ->
            "RAM"

        NIC ->
            "NIC"

        USB ->
            "USB"

        MOB ->
            "Motherboard"
