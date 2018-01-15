module Game.Servers.Hardware.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Account as Account
import Utils.Update as Update
import Events.Server.Hardware.MotherboardUpdated as MotherboardUpdated
import Game.Models as Game
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Meta.Types.Components.Motherboard.Diff as Motherboard
import Game.Servers.Hardware.Requests.UpdateMotherboard as UpdateMotherboard
import Game.Servers.Shared as Servers exposing (CId)
import Game.Servers.Hardware.Requests exposing (..)
import Game.Servers.Hardware.Messages exposing (..)
import Game.Servers.Hardware.Models exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> CId -> Msg -> Model -> UpdateResponse
update game cid msg model =
    case msg of
        HandleMotherboardUpdated data ->
            handleMotherboardUpdated data model

        HandleMotherboardUpdate data ->
            handleMotherboardUpdate game cid data model

        Request response ->
            onRequest game cid (receive response) model


handleMotherboardUpdated :
    MotherboardUpdated.Data
    -> Model
    -> UpdateResponse
handleMotherboardUpdated model_ model =
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



--handleMotherboardDetached :
--    MotherboardDetached.Data
--    -> Model
--    -> UpdateResponse
--handleMotherboardDetached data model =
--    case getMotherboard model of
--        Just oldMotherboard ->
--            let
--                newMotherboard =
--                    Motherboard.empty
--                model_ =
--                    setMotherboard (Just newMotherboard) model
--                dispatch =
--                    oldMotherboard
--                        |> Motherboard.diff newMotherboard
--                        |> dispatchDiff
--            in
--                ( model_, Cmd.none, dispatch )
--        Nothing ->
--            Update.fromModel model


handleMotherboardUpdate :
    Game.Model
    -> CId
    -> Motherboard
    -> Model
    -> UpdateResponse
handleMotherboardUpdate game cid motherboard model =
    let
        cmd =
            UpdateMotherboard.request motherboard cid game
                |> Debug.log "CMD"
    in
        ( model, cmd, Dispatch.none )


onRequest : Game.Model -> CId -> Maybe Response -> Model -> UpdateResponse
onRequest game cid request model =
    case request of
        Just (UpdateMotherboard response) ->
            onUpdateMotherboard response model

        Nothing ->
            Update.fromModel model


onUpdateMotherboard : UpdateMotherboard.Response -> Model -> UpdateResponse
onUpdateMotherboard response model =
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
