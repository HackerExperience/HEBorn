module Decoders.Account exposing (..)

import Json.Decode as Decode exposing (Decoder, map, field, string, succeed, oneOf)
import Json.Decode.Pipeline exposing (decode, required, hardcoded, optional)
import Game.Account.Models exposing (..)
import Game.Servers.Shared as Servers


account : Model -> Decoder Model
account model =
    decode Model
        |> hardcoded model.id
        |> hardcoded model.username
        |> hardcoded model.auth
        |> hardcoded model.inTutorial
        |> hardcoded model.email
        |> hardcoded model.database
        |> hardcoded model.dock
        |> hardcoded model.gateways
        |> hardcoded model.activeGateway
        |> hardcoded model.context
        |> hardcoded model.bounces
        |> hardcoded model.notifications
        |> hardcoded model.logout
        |> mainframe model
        |> hardcoded model.campaignGateway


mainframe : Model -> Decoder (Maybe Servers.CId -> b) -> Decoder b
mainframe model =
    required "mainframe" (map (Servers.GatewayCId >> Just) string)


campaignGateway : Model -> Decoder (Maybe Servers.CId -> b) -> Decoder b
campaignGateway model =
    required "campaign_gateway" (map (Servers.GatewayCId >> Just) string)
