module Game.Servers.Hardware.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Servers.Shared as Servers exposing (CId)
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Meta.Types.Components.Motherboard.Diff as Motherboard
import Game.Servers.Hardware.Requests.UpdateMotherboard as UpdateMotherboard exposing (updateMotherboardRequest)
import Game.Servers.Hardware.Config exposing (..)
import Game.Servers.Hardware.Models exposing (..)
import Game.Servers.Hardware.Messages exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        HandleMotherboardUpdate motherboard ->
            handleMotherboardUpdate config motherboard model

        HandleMotherboardUpdated model_ ->
            handleMotherboardUpdated config model_ model

        SetMotherboard motherboard ->
            ( setMotherboard (Just motherboard) model, React.none )


handleMotherboardUpdate :
    Config msg
    -> Motherboard
    -> Model
    -> UpdateResponse msg
handleMotherboardUpdate config motherboard model =
    let
        handler result =
            case result of
                Ok motherboard ->
                    config.toMsg <| SetMotherboard motherboard

                Err error ->
                    config.batchMsg []

        cmd =
            config
                |> updateMotherboardRequest motherboard config.cid
                |> Cmd.map handler
                |> React.cmd
    in
        ( model, cmd )


handleMotherboardUpdated :
    Config msg
    -> Model
    -> Model
    -> UpdateResponse msg
handleMotherboardUpdated config model_ model =
    let
        motherboard =
            model_
                |> getMotherboard
                |> Maybe.withDefault Motherboard.empty

        ( used, freed ) =
            model
                |> getMotherboard
                |> Maybe.withDefault Motherboard.empty
                |> Motherboard.diff motherboard
                |> Tuple.mapFirst
                    (List.map config.onInventoryUsed >> config.batchMsg)
                |> Tuple.mapSecond
                    (List.map config.onInventoryFreed >> config.batchMsg)

        cmd =
            React.msg <| config.batchMsg [ used, freed ]
    in
        ( model_, cmd )
