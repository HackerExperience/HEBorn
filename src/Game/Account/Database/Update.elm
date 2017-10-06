module Game.Account.Database.Update exposing (update)

import Dict exposing (Dict)
import Json.Decode exposing (Value, decodeValue)
import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Messages as Core
import Utils.Update as Update
import Driver.Websocket.Channels exposing (..)
import Driver.Websocket.Reports as Ws
import Driver.Websocket.Messages as Ws
import Events.Events as Events exposing (Event(Report, AccountEvent))
import Events.Account as EventsAccount
import Events.Account.Database as EventsDatabase
import Requests.Requests as Requests
import Game.Account.Database.Models exposing (..)
import Game.Account.Database.Messages exposing (..)
import Game.Models as Game


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        Event event ->
            updateEvent game event model


updateEvent : Game.Model -> Events.Event -> Model -> UpdateResponse
updateEvent game event model =
    let
        databaseEvents event =
            case event of
                EventsDatabase.PasswordAcquired data ->
                    onPasswordAcquired game data model

        accountEvents event =
            case event of
                EventsAccount.DatabaseEvent event ->
                    databaseEvents event

                _ ->
                    Update.fromModel model
    in
        case event of
            AccountEvent event ->
                accountEvents event

            _ ->
                Update.fromModel model


{-| Saves password for that server, inserts a new server entry
if none is found.
-}
onPasswordAcquired :
    Game.Model
    -> EventsDatabase.PasswordAcquiredData
    -> Model
    -> UpdateResponse
onPasswordAcquired game data model =
    let
        servers =
            getHackedServers model

        model_ =
            servers
                |> getHackedServer data.nip
                |> setPassword data.password
                |> flip (insertServer data.nip) servers
                |> flip setHackedServers model
    in
        -- TODO: we need a new hacked server request here
        Update.fromModel model_
