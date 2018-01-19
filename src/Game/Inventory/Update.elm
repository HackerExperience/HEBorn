module Game.Inventory.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Inventory.Config exposing (..)
import Game.Inventory.Messages exposing (..)
import Game.Inventory.Models exposing (..)
import Game.Inventory.Shared exposing (..)


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        HandleComponentUsed entry ->
            handleComponentUsed config entry model

        HandleComponentFreed entry ->
            handleComponentFreed config entry model


handleComponentUsed : Config msg -> Entry -> Model -> UpdateResponse msg
handleComponentUsed config entry model =
    model
        |> setAvailability False entry
        |> Update.fromModel


handleComponentFreed : Config msg -> Entry -> Model -> UpdateResponse msg
handleComponentFreed config entry model =
    model
        |> setAvailability True entry
        |> Update.fromModel
