module Game.Inventory.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Events.Server.Hardware.ComponentLinked as ComponentLinked
import Events.Server.Hardware.ComponentUnlinked as ComponentUnlinked
import Game.Models as Game
import Game.Inventory.Messages exposing (..)
import Game.Inventory.Models exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Msg -> Model -> UpdateResponse
update msg model =
    case msg of
        HandleComponentLinked data ->
            handleComponentLinked data model

        HandleComponentUnlinked data ->
            handleComponentUnlinked data model


handleComponentLinked :
    ComponentLinked.Data
    -> Model
    -> UpdateResponse
handleComponentLinked data model =
    model
        |> setAvailability False (Component data.componentId)
        |> Update.fromModel


handleComponentUnlinked :
    ComponentUnlinked.Data
    -> Model
    -> UpdateResponse
handleComponentUnlinked data model =
    model
        |> setAvailability True (Component data.componentId)
        |> Update.fromModel
