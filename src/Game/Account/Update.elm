module Game.Account.Update exposing (update)

import Json.Decode exposing (Value, decodeValue)
import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Messages as Core
import Driver.Websocket.Channels exposing (..)
import Driver.Websocket.Reports as Ws
import Driver.Websocket.Messages as Ws
import Events.Events as Events exposing (Event(Report, AccountEvent))
import Requests.Requests as Requests
import Game.Servers.Shared as Servers
import Game.Servers.Messages as Servers
import Game.Servers.Models as Servers
import Game.Notifications.Messages as Notifications
import Game.Notifications.Update as Notifications
import Game.Network.Types exposing (NIP)
import Game.Meta.Types exposing (..)
import Game.Account.Database.Messages as Database
import Game.Account.Database.Update as Database
import Game.Account.Bounces.Update as Bounces
import Game.Account.Messages exposing (..)
import Game.Account.Models exposing (..)
import Game.Account.Requests exposing (..)
import Game.Account.Requests.Logout as Logout
import Game.Account.Bounces.Messages as Bounces
import Game.Models as Game


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        DoLogout ->
            onDoLogout game model

        SetGateway nip ->
            onSetGateway game nip model

        SetEndpoint nip ->
            onSetEndpoint game nip model

        InsertEndpoint nip ->
            onInsertEndpoint nip model

        ContextTo context ->
            onContextTo game context model

        BouncesMsg msg ->
            onBounce game msg model

        DatabaseMsg msg ->
            onDatabase game msg model

        NotificationsMsg msg ->
            onNotifications game msg model

        Event data ->
            onEvent game data model

        Request data ->
            onRequest game (receive data) model



-- internals


onSetGateway : Game.Model -> NIP -> Model -> UpdateResponse
onSetGateway game nip model =
    Update.fromModel { model | activeGateway = Just nip }


onSetEndpoint : Game.Model -> Maybe NIP -> Model -> UpdateResponse
onSetEndpoint game nip model =
    case getGateway model of
        Just gateway ->
            let
                setEndpoint id =
                    Dispatch.server id <| Servers.SetEndpoint nip

                dispatch =
                    game
                        |> Game.getServers
                        |> Servers.mapNetwork gateway
                        |> Maybe.map setEndpoint
                        |> Maybe.withDefault Dispatch.none

                model_ =
                    if nip == Nothing then
                        ensureValidContext game { model | context = Gateway }
                    else
                        ensureValidContext game model
            in
                ( model_, Cmd.none, dispatch )

        Nothing ->
            Update.fromModel model


onContextTo : Game.Model -> Context -> Model -> UpdateResponse
onContextTo game context model =
    let
        model1 =
            { model | context = context }

        model_ =
            ensureValidContext game model1
    in
        ( model_, Cmd.none, Dispatch.none )


onDatabase : Game.Model -> Database.Msg -> Model -> UpdateResponse
onDatabase game msg model =
    Update.child
        { get = .database
        , set = (\database model -> { model | database = database })
        , toMsg = DatabaseMsg
        , update = (Database.update game)
        }
        msg
        model


onNotifications : Game.Model -> Notifications.Msg -> Model -> UpdateResponse
onNotifications game msg model =
    Update.child
        { get = .notifications
        , set = (\notifications model -> { model | notifications = notifications })
        , toMsg = NotificationsMsg
        , update = (Notifications.update game)
        }
        msg
        model


onDoLogout : Game.Model -> Model -> UpdateResponse
onDoLogout game model =
    let
        model_ =
            { model | logout = True }

        token =
            getToken model

        cmd =
            Logout.request token game
    in
        ( model_, cmd, Dispatch.none )


onBounce : Game.Model -> Bounces.Msg -> Model -> UpdateResponse
onBounce game msg model =
    let
        ( bounces, cmd, dispatch ) =
            Bounces.update game msg model.bounces

        cmd_ =
            Cmd.map BouncesMsg cmd

        model_ =
            { model | bounces = bounces }
    in
        ( model_, cmd_, dispatch )


onEvent : Game.Model -> Events.Event -> Model -> UpdateResponse
onEvent game event model =
    model
        |> onDatabase game (Database.Event event)
        |> Update.andThen (updateEvent game event)


onRequest : Game.Model -> Maybe Response -> Model -> UpdateResponse
onRequest game response model =
    case response of
        Just response ->
            updateResponse game response model

        Nothing ->
            Update.fromModel model


updateEvent : Game.Model -> Events.Event -> Model -> UpdateResponse
updateEvent game event model =
    case event of
        Report (Ws.Connected _) ->
            onWsConnected game model

        Report Ws.Disconnected ->
            onWsDisconnected game model

        _ ->
            Update.fromModel model


updateResponse : Game.Model -> Response -> Model -> UpdateResponse
updateResponse game response model =
    case response of
        _ ->
            Update.fromModel model


onWsConnected : Game.Model -> Model -> UpdateResponse
onWsConnected game model =
    let
        dispatch =
            Dispatch.websocket
                (Ws.JoinChannel (AccountChannel model.id) Nothing)
    in
        ( model, Cmd.none, dispatch )


onWsDisconnected : Game.Model -> Model -> UpdateResponse
onWsDisconnected game model =
    let
        dispatch =
            if model.logout then
                Dispatch.core Core.Shutdown
            else
                Dispatch.none
    in
        ( model, Cmd.none, dispatch )


ensureValidContext : Game.Model -> Model -> Model
ensureValidContext game model =
    let
        servers =
            Game.getServers game

        endpoint =
            model
                |> getGateway
                |> Maybe.andThen (flip Servers.getByNIP servers)
                |> Maybe.andThen Servers.getEndpoint
                |> Maybe.andThen (flip Servers.get servers)
                |> Maybe.map Servers.getNIP
    in
        if getContext model == Endpoint && endpoint == Nothing then
            { model | context = Gateway }
        else
            model


onInsertEndpoint : NIP -> Model -> UpdateResponse
onInsertEndpoint nip model =
    model
        |> insertEndpoint nip
        |> Update.fromModel
