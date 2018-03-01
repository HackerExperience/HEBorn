module Decoders.Account exposing (..)

import Dict as Dict
import Json.Decode as Decode exposing (Decoder, map, field, string, succeed, oneOf)
import Json.Decode.Pipeline exposing (decode, required, hardcoded, optional)
import Decoders.Bounces exposing (bounces)
import Game.Account.Models exposing (..)
import Game.Account.Bounces.Dummy as Bounces
import Game.Account.Database.Dummy as Database
import Game.Account.Finances.Dummy as Finances
import Game.Servers.Shared as Servers


account : Model -> Decoder Model
account model =
    decode Model
        |> hardcoded model.id
        |> hardcoded model.username
        |> hardcoded model.auth
        |> hardcoded model.inTutorial
        |> hardcoded model.email
        |> hardcoded Database.dummy
        |> hardcoded model.dock
        |> hardcoded model.gateways
        |> hardcoded model.activeGateway
        |> hardcoded model.context
        --optional "bounces" bounces Dict.empty
        |> hardcoded Bounces.dummy
        |> hardcoded Finances.dummy
        |> hardcoded model.notifications
        |> hardcoded model.signOut
        |> mainframe


mainframe : Decoder (Maybe Servers.CId -> b) -> Decoder b
mainframe =
    required "mainframe" (map (Servers.GatewayCId >> Just) string)
