module Game.Account.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Messages as Core
import Driver.Websocket.Channels exposing (..)
import Driver.Websocket.Messages as Ws
import Game.Servers.Shared as Servers
import Game.Servers.Messages as Servers
import Game.Servers.Models as Servers
import Game.Notifications.Messages as Notifications
import Game.Notifications.Update as Notifications
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

        DoCrash code message ->
            onDoCrash game code message model

        SetGateway cid ->
            onSetGateway game cid model

        SetEndpoint cid ->
            onSetEndpoint game cid model

        InsertGateway cid ->
            onInsertGateway cid model

        ContextTo context ->
            onContextTo game context model

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

        HandleConnect ->
            handleConnect model

        HandleDisconnect ->
            handleDisconnect model



-- internals


onSetGateway : Game.Model -> Servers.CId -> Model -> UpdateResponse
onSetGateway game cid model =
    Update.fromModel { model | activeGateway = Just cid }


onSetEndpoint :
    Game.Model
    -> Maybe Servers.CId
    -> Model
    -> UpdateResponse
onSetEndpoint game endpointId model =
    case getGateway model of
        Just gateway ->
            let
                setEndpoint gatewayId =
                    Dispatch.server gatewayId <|
                        Servers.SetEndpoint endpointId

                dispatch =
                    model
                        |> getGateway
                        |> Maybe.map setEndpoint
                        |> Maybe.withDefault Dispatch.none

                model_ =
                    if endpointId == Nothing then
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
            { model | logout = ToLanding }

        token =
            getToken model

        cmd =
            Logout.request token game
    in
        ( model_, cmd, Dispatch.none )


onDoCrash : Game.Model -> String -> String -> Model -> UpdateResponse
onDoCrash game code message model =
    let
        model_ =
            { model | logout = ToCrash code message }

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


onInsertGateway : Servers.CId -> Model -> UpdateResponse
onInsertGateway cid model =
    model
        |> insertGateway cid
        |> Update.fromModel


handleConnect : Model -> UpdateResponse
handleConnect model =
    let
        dispatch =
            Dispatch.websocket
                (Ws.JoinChannel (AccountChannel model.id) Nothing)
    in
        ( model, Cmd.none, dispatch )


handleDisconnect : Model -> UpdateResponse
handleDisconnect model =
    let
        dispatch =
            case model.logout of
                ToLanding ->
                    Dispatch.core Core.Shutdown

                ToCrash code message ->
                    Dispatch.core <| Core.Crash code message

                _ ->
                    Dispatch.none
    in
        ( model, Cmd.none, dispatch )
