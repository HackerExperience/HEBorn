module Game.Servers.Hardware.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Events.Server.Hardware.ComponentLinked as ComponentLinked
import Events.Server.Hardware.ComponentUnlinked as ComponentUnlinked
import Events.Server.Hardware.MotherboardAttached as MotherboardAttached
import Events.Server.Hardware.MotherboardDetached as MotherboardDetached
import Game.Models as Game
import Game.Meta.Types.Components.Motherboard as Motherboard
import Game.Servers.Shared as Servers exposing (CId)
import Game.Servers.Hardware.Messages exposing (..)
import Game.Servers.Hardware.Models exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> CId -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update game cid msg model =
    case msg of
        HandleComponentLinked data ->
            handleComponentLinked data model

        HandleComponentUnlinked data ->
            handleComponentUnlinked data model

        HandleMotherboardAttached data ->
            handleMotherboardAttached data

        HandleMotherboardDetached data ->
            handleMotherboardDetached data model


handleComponentLinked :
    ComponentLinked.Data
    -> Model
    -> UpdateResponse
handleComponentLinked data model =
    model
        |> getMotherboard
        |> Maybe.map (Motherboard.linkComponent data.slotId data.componentId)
        |> flip setMotherboard model
        |> Update.fromModel


handleComponentUnlinked :
    ComponentUnlinked.Data
    -> Model
    -> UpdateResponse
handleComponentUnlinked data model =
    model
        |> getMotherboard
        |> Maybe.map (Motherboard.unlinkComponent data.slotId)
        |> flip setMotherboard model
        |> Update.fromModel


handleMotherboardAttached :
    MotherboardAttached.Data
    -> UpdateResponse
handleMotherboardAttached newModel =
    Update.fromModel newModel


handleMotherboardDetached :
    MotherboardDetached.Data
    -> Model
    -> UpdateResponse
handleMotherboardDetached data model =
    model
        |> setMotherboard (Just Motherboard.empty)
        |> Update.fromModel
