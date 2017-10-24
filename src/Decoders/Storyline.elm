module Decoders.Storyline exposing (..)

import Dict
import Json.Decode as Decode
    exposing
        ( Decoder
        , bool
        )
import Json.Decode.Pipeline exposing (decode, required, optional)
import Game.Storyline.Models exposing (..)
import Game.Storyline.Missions.Models as Missions
import Decoders.Emails exposing (..)
import Decoders.Missions exposing (..)


story : Decoder Model
story =
    decode Model
        |> optional "enabled" bool False
        |> optional "mission" mission Missions.initialModel
        |> required "email" emails
