module Game.Inventory.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Models as Game
import Game.Inventory.Messages exposing (..)
import Game.Inventory.Models exposing (..)
import Game.Inventory.Shared exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Msg -> Model -> UpdateResponse
update msg model =
    case msg of
        HandleComponentUsed entry ->
            handleComponentUsed entry model

        HandleComponentFreed entry ->
            handleComponentFreed entry model


handleComponentUsed : Entry -> Model -> UpdateResponse
handleComponentUsed entry model =
    model
        |> setAvailability False entry
        |> Update.fromModel


handleComponentFreed : Entry -> Model -> UpdateResponse
handleComponentFreed entry model =
    model
        |> setAvailability True entry
        |> Update.fromModel
