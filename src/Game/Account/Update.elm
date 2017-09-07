module Game.Account.Update exposing (update, bootstrap)

import Json.Decode exposing (Value, decodeValue)
import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Messages as Core
import Driver.Websocket.Channels exposing (..)
import Driver.Websocket.Reports as Ws
import Driver.Websocket.Messages as Ws
import Events.Events as Events exposing (Event(Report, AccountEvent))
import Events.Account as Account exposing (AccountHolder)
import Requests.Requests as Requests
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

        BouncesMsg msg ->
            onBounce game msg model

        Event data ->
            onEvent game data model

        Request data ->
            onRequest game (receive data) model

        Bootstrap json ->
            onBootstrap json model


bootstrap : Value -> Model -> Model
bootstrap json model =
    decodeValue Account.decoder json
        |> Requests.report
        |> Maybe.map (merge model)
        |> Maybe.withDefault model


-- internals

onDatabase : Account.Msg -> Model -> UpdateResponse
onDatabase msg game =
    Update.child
        { get = .database
        , set = (\database game -> { game | database = database })
        , toMsg = DatabaseMsg
        , update = (Database.update game)
        }
        msg
        game

onBootstrap : Value -> Model -> UpdateResponse
onBootstrap json model =
    Update.fromModel <| bootstrap json model


merge : Model -> AccountHolder -> Model
merge src new =
    { id =
        src.id
    , username =
        src.username
    , auth =
        src.auth
    , email =
        new.email
    , database =
        -- TODO: remake bootstrap
        --Maybe.withDefault src.database <| new.database
        src.database
    , dock =
        Maybe.withDefault src.dock <| new.dock
    , servers =
        new.servers
    , activeGateway =
        new.activeGateway
    , bounces =
        Maybe.withDefault src.bounces <| new.bounces
    , inventory =
        Maybe.withDefault src.inventory <| new.inventory
    , logout =
        src.logout
    }


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
    onDatabase (Database.Event event) model


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

        Report (Ws.Joined AccountChannel) ->
            -- TODO: maybe remove this handler
            onWsJoinedAccount game model

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
                (Ws.JoinChannel AccountChannel (Just model.id) Nothing)
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
