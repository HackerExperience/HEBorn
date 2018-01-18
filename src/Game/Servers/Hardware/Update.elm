module Game.Servers.Hardware.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Account as Account
import Events.Server.Hardware.MotherboardUpdated as MotherboardUpdated
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Meta.Types.Components.Motherboard.Diff as Motherboard
import Game.Servers.Shared as Servers exposing (CId)
import Game.Servers.Hardware.Config exposing (..)
import Game.Servers.Hardware.Models exposing (..)
import Game.Servers.Hardware.Messages exposing (..)
import Game.Servers.Hardware.Requests exposing (..)
import Game.Servers.Hardware.Requests.UpdateMotherboard as UpdateMotherboard


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        HandleMotherboardUpdated data ->
            handleMotherboardUpdated config data model

        HandleMotherboardUpdate data ->
            handleMotherboardUpdate config data model

        Request response ->
            onRequest config (receive response) model


handleMotherboardUpdated :
    Config msg
    -> MotherboardUpdated.Data
    -> Model
    -> UpdateResponse msg
handleMotherboardUpdated config model_ model =
    let
        oldMotherboard =
            model
                |> getMotherboard
                |> Maybe.withDefault Motherboard.empty

        newMotherboard =
            model_
                |> getMotherboard
                |> Maybe.withDefault Motherboard.empty

        dispatch =
            oldMotherboard
                |> Motherboard.diff newMotherboard
                |> dispatchDiff
    in
        ( model_, Cmd.none, dispatch )


handleMotherboardUpdate :
    Config msg
    -> Motherboard
    -> Model
    -> UpdateResponse msg
handleMotherboardUpdate config motherboard model =
    ( model
    , Cmd.map config.toMsg <|
        UpdateMotherboard.request motherboard config.cid config
    , Dispatch.none
    )


onRequest :
    Config msg
    -> Maybe Response
    -> Model
    -> UpdateResponse msg
onRequest config request model =
    case request of
        Just (UpdateMotherboard response) ->
            onUpdateMotherboard config response model

        Nothing ->
            Update.fromModel model


onUpdateMotherboard :
    Config msg
    -> UpdateMotherboard.Response
    -> Model
    -> UpdateResponse msg
onUpdateMotherboard config response model =
    case response of
        UpdateMotherboard.Okay motherboard ->
            model
                |> setMotherboard (Just motherboard)
                |> Update.fromModel

        _ ->
            Update.fromModel model



-- helpers


dispatchDiff : Motherboard.Diff -> Dispatch
dispatchDiff =
    let
        dispatchUsed =
            List.map
                (Account.UsedInventoryEntry
                    >> Account.Inventory
                    >> Dispatch.account
                )
                >> Dispatch.batch

        dispatchFreed =
            List.map
                (Account.FreedInventoryEntry
                    >> Account.Inventory
                    >> Dispatch.account
                )
                >> Dispatch.batch

        dispatch ( used, freed ) =
            Dispatch.batch
                [ dispatchUsed used
                , dispatchFreed freed
                ]
    in
        dispatch
