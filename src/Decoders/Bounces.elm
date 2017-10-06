module Decoders.Bounces exposing (..)

import Json.Decode as Decode
    exposing
        ( Decoder
        , dict
        , list
        , string
        )
import Json.Decode.Pipeline exposing (decode, required)
import Game.Account.Bounces.Models exposing (..)
import Game.Network.Types exposing (NIP)
import Apps.Apps as Apps


bounces : Decoder Model
bounces =
    dict bounce


bounce : Decoder Bounce
bounce =
    decode Bounce
        |> required "name" string
        |> required "path" (list nip)


nip : Decoder NIP
nip =
    decode (,)
        |> required "netid" string
        |> required "ip" string
