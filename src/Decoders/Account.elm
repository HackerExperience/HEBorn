module Decoders.Account exposing (..)

import Json.Decode as Decode exposing (Decoder, map, field, string, succeed, oneOf)
import Json.Decode.Pipeline exposing (decode, required, hardcoded, optional)
import Game.Account.Models exposing (..)
import Game.Servers.Shared as Servers
import Setup.Types as Setup
import Setup.Models as Setup
import Decoders.Servers
import Decoders.Setup


account : Model -> Decoder Model
account model =
    decode Model
        |> hardcoded model.id
        |> hardcoded model.username
        |> hardcoded model.auth
        |> hardcoded model.email
        |> hardcoded model.database
        |> hardcoded model.dock
        |> hardcoded model.gateways
        |> hardcoded model.activeGateway
        |> hardcoded model.context
        |> hardcoded model.activeNetwork
        |> hardcoded model.bounces
        |> hardcoded model.userBounces
        |> hardcoded model.inventory
        |> hardcoded model.notifications
        |> hardcoded model.logout
        |> mainframe model


mainframe : Model -> Decoder (Maybe Servers.CId -> b) -> Decoder b
mainframe model =
    required "mainframe" (map (Servers.GatewayCId >> Just) string)
