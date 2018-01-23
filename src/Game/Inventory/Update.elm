module Game.Inventory.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Inventory.Config exposing (..)
import Game.Inventory.Messages exposing (..)
import Game.Inventory.Models exposing (..)
import Game.Inventory.Shared exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        HandleComponentUsed entry ->
            handleComponentUsed config entry model

        HandleComponentFreed entry ->
            handleComponentFreed config entry model


handleComponentUsed : Config msg -> Entry -> Model -> UpdateResponse msg
handleComponentUsed config entry model =
    ( setAvailability False entry model, React.none )


handleComponentFreed : Config msg -> Entry -> Model -> UpdateResponse msg
handleComponentFreed config entry model =
    ( setAvailability True entry model, React.none )
