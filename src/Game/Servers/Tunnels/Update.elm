module Game.Servers.Tunnels.Update exposing (update, bootstrap)

import Dict exposing (Dict)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Events.Events as Events exposing (Event(ServersEvent))
import Events.Servers exposing (Event(ServerEvent), ServerEvent(TunnelsEvent))
import Events.Servers.Tunnels as Tunnels
import Game.Models as Game
import Json.Decode exposing (Value, decodeValue)
import Utils.Update as Update
import Game.Network.Types as Network
import Game.Servers.Tunnels.Messages exposing (..)
import Game.Servers.Tunnels.Models exposing (..)
import Decoders.Tunnels


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        Event ev ->
            updateEvent game ev model

        Request data ->
            Update.fromModel model


bootstrap : Value -> Model -> Model
bootstrap json model =
    decodeValue Decoders.Tunnels.index json
        |> Result.mapError (Debug.log "Invalid Bootstrap for Tunnels")
        |> Result.map Dict.fromList
        |> Result.withDefault model



-- internals


updateEvent : Game.Model -> Events.Event -> Model -> UpdateResponse
updateEvent game event model =
    case event of
        ServersEvent (ServerEvent _ (TunnelsEvent (Tunnels.Changed data))) ->
            Update.fromModel (Dict.fromList data)

        _ ->
            Update.fromModel model
