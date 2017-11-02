module Decoders.Account exposing (..)

import Json.Decode as Decode exposing (Decoder, map, field, succeed, oneOf)
import Json.Decode.Pipeline exposing (decode, hardcoded, optional)
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
        |> hardcoded model.bounces
        |> hardcoded model.inventory
        |> hardcoded model.notifications
        |> hardcoded model.logout
        |> mainframe model


mainframe : Model -> Decoder (Maybe Servers.CId -> b) -> Decoder b
mainframe model =
    optional "mainframe" (map Just Decoders.Servers.playerCId) model.mainframe


setupPages : Decoder Setup.Pages
setupPages =
    -- TODO: remove this fallback after getting helix support
    oneOf
        [ succeed Setup.pageOrder
        , Decoders.Setup.remainingPages
            |> field "pages"
            |> field "setup"
            |> field "account"
        ]
