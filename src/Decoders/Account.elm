module Decoders.Account exposing (..)

import Json.Decode as Decode exposing (Decoder, map)
import Json.Decode.Pipeline exposing (decode, hardcoded, optional)
import Game.Account.Models exposing (..)
import Game.Servers.Shared as Servers
import Decoders.Servers


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
        |> hardcoded model.bounces
        |> hardcoded model.inventory
        |> hardcoded model.notifications
        |> hardcoded model.logout
        |> mainframe model


mainframe : Model -> Decoder (Maybe Servers.CId -> b) -> Decoder b
mainframe model =
    optional "mainframe" (map Just Decoders.Servers.cid) model.mainframe
