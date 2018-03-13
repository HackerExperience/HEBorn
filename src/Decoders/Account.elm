module Decoders.Account exposing (..)

import Json.Decode as Decode exposing (Decoder, map, field, string, succeed, oneOf)
import Json.Decode.Pipeline exposing (decode, required, hardcoded, optional)
import Decoders.Bounces exposing (bounces)
import Decoders.Database exposing (database)
import Decoders.Finances exposing (finances)
import Game.Account.Models exposing (..)
import Game.Account.Database.Models as Database
import Game.Account.Finances.Models as Finances
import Game.Servers.Shared as Servers


account : Model -> Decoder Model
account model =
    decode Model
        |> hardcoded model.id
        |> hardcoded model.username
        |> hardcoded model.auth
        |> hardcoded model.inTutorial
        |> hardcoded model.email
        |> required "database" database
        |> hardcoded model.dock
        |> hardcoded model.gateways
        |> hardcoded model.activeGateway
        |> hardcoded model.context
        |> required "bounces" bounces
        --required "finances" finances
        |> hardcoded model.finances
        |> hardcoded model.notifications
        |> hardcoded model.signOut
        |> mainframe


mainframe : Decoder (Maybe Servers.CId -> b) -> Decoder b
mainframe =
    required "mainframe" (map (Servers.GatewayCId >> Just) string)
