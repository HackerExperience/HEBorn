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
    decodeValue Tunnels.decoder json
        |> Result.mapError (Debug.log "Invalid Bootstrap for Tunnels")
        |> Result.map toModel
        |> Result.withDefault model



-- internals


toModel : Tunnels.Index -> Model
toModel index =
    let
        model =
            initialModel

        insertConnections conn tunnel =
            insertConnection conn.id (newConnection conn.type_) tunnel

        insertTunnels tunn model =
            let
                id =
                    toTunnelID tunn.bounce tunn.nip

                tunnel =
                    getTunnel id model

                tunnel_ =
                    List.foldl insertConnections tunnel tunn.connections

                model_ =
                    insertTunnel id tunnel_ model
            in
                model_
    in
        List.foldl insertTunnels model index


updateEvent : Game.Model -> Events.Event -> Model -> UpdateResponse
updateEvent game event model =
    case event of
        ServersEvent (ServerEvent _ (TunnelsEvent (Tunnels.Changed data))) ->
            Update.fromModel (toModel data)

        _ ->
            Update.fromModel model
