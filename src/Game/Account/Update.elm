module Game.Account.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Core as Core
import Core.Dispatch.Servers as Servers
import Core.Error as Error exposing (Error)
import Core.Dispatch.Websocket as Ws
import Driver.Websocket.Channels exposing (Channel(AccountChannel))
import Game.Servers.Shared as Servers
import Game.Servers.Models as Servers
import Game.Notifications.Messages as Notifications
import Game.Notifications.Source as Notifications
import Game.Notifications.Update as Notifications
import Game.Meta.Types.Context exposing (..)
import Game.Notifications.Source as Notifications
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
        BouncesMsg msg ->
            onBounce game msg model

        DatabaseMsg msg ->
            onDatabase game msg model

        NotificationsMsg msg ->
            onNotifications game msg model

        Request data ->
            data
                |> receive
                |> Maybe.map (flip (updateRequest game) model)
                |> Maybe.withDefault (Update.fromModel model)

        HandleLogout ->
            handleLogout game model

        HandleSetGateway cid ->
            handleSetGateway game cid model

        HandleSetEndpoint mCid ->
            handleSetEndpoint game mCid model

        HandleSetContext context ->
            handleSetContext game context model

        HandleNewGateway cid ->
            handleNewGateway cid model

        HandleLogoutAndCrash error ->
            handleLogoutAndCrash game error model

        HandleConnected ->
            handleConnected model

        HandleDisconnected ->
            handleDisconnected model



-- internals


handleSetGateway : Game.Model -> Servers.CId -> Model -> UpdateResponse
handleSetGateway game cid model =
    Update.fromModel { model | activeGateway = Just cid }


handleSetEndpoint :
    Game.Model
    -> Maybe Servers.CId
    -> Model
    -> UpdateResponse
handleSetEndpoint game cid model =
    case getGateway model of
        Just gateway ->
            let
                setEndpoint gatewayId =
                    Dispatch.server gatewayId <|
                        Servers.SetEndpoint cid

                dispatch =
                    model
                        |> getGateway
                        |> Maybe.map setEndpoint
                        |> Maybe.withDefault Dispatch.none

                model_ =
                    if cid == Nothing then
                        ensureValidContext game { model | context = Gateway }
                    else
                        ensureValidContext game model
            in
                ( model_, Cmd.none, dispatch )

        Nothing ->
            Update.fromModel model


handleSetContext : Game.Model -> Context -> Model -> UpdateResponse
handleSetContext game context model =
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
        , update = (Notifications.update game Notifications.Account)
        }
        msg
        model


handleLogout : Game.Model -> Model -> UpdateResponse
handleLogout game model =
    let
        model_ =
            { model | logout = ToLanding }

        token =
            getToken model

        cmd =
            Logout.request token model.id game
    in
        ( model_, cmd, Dispatch.none )


handleLogoutAndCrash : Game.Model -> Error -> Model -> UpdateResponse
handleLogoutAndCrash game error model =
    let
        model_ =
            { model | logout = ToCrash error }

        token =
            getToken model

        cmd =
            Logout.request token model.id game
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


updateRequest : Game.Model -> Response -> Model -> UpdateResponse
updateRequest game response model =
    case response of
        _ ->
            Update.fromModel model


ensureValidContext : Game.Model -> Model -> Model
ensureValidContext game model =
    let
        servers =
            Game.getServers game

        endpoint =
            model
                |> getGateway
                |> Maybe.andThen (flip Servers.get servers)
                |> Maybe.andThen Servers.getEndpointCId
    in
        if getContext model == Endpoint && endpoint == Nothing then
            { model | context = Gateway }
        else
            model


handleNewGateway : Servers.CId -> Model -> UpdateResponse
handleNewGateway cid model =
    model
        |> insertGateway cid
        |> Update.fromModel


handleConnected : Model -> UpdateResponse
handleConnected model =
    let
        dispatch =
            Dispatch.websocket <|
                Ws.Join (AccountChannel model.id) Nothing
    in
        ( model, Cmd.none, dispatch )


handleDisconnected : Model -> UpdateResponse
handleDisconnected model =
    let
        dispatch =
            case model.logout of
                ToLanding ->
                    Dispatch.core <| Core.Shutdown

                ToCrash error ->
                    Dispatch.core <| Core.Crash error

                _ ->
                    Dispatch.none
    in
        ( model, Cmd.none, dispatch )
