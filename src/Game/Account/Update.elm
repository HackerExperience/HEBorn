module Game.Account.Update exposing (..)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Messages as Core
import Utils.Update as Update
import Driver.Websocket.Channels exposing (..)
import Driver.Websocket.Reports as Ws
import Driver.Websocket.Messages as Ws
import Events.Events as Events
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

        BouncesMsg msg ->
            onBounce game msg model

        Event data ->
            onEvent game data model

        Request data ->
            onRequest game (receive data) model



-- internals


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
    -- TODO: route events to Bounces, Database and Inventory.
    updateEvent game event model


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
        Events.Report (Ws.Connected _) ->
            onWsConnected game model

        Events.Report (Ws.Joined AccountChannel) ->
            -- TODO: maybe remove this handler
            onWsJoinedAccount game model

        Events.Report Ws.Disconnected ->
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
                (Ws.JoinChannel AccountChannel (Just model.id))
    in
        ( model, Cmd.none, dispatch )


onWsJoinedAccount : Game.Model -> Model -> UpdateResponse
onWsJoinedAccount game model =
    -- TODO: maybe remove this function
    Update.fromModel model


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
