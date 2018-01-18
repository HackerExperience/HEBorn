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
import Game.Account.Finances.Models as Finances
import Game.Account.Finances.Messages as Finances
import Game.Account.Finances.Update as Finances
import Game.Account.Database.Messages as Database
import Game.Account.Database.Update as Database
import Game.Account.Bounces.Update as Bounces
import Game.Account.Config exposing (..)
import Game.Account.Messages exposing (..)
import Game.Account.Models exposing (..)
import Game.Account.Requests exposing (..)
import Game.Account.Requests.Logout as Logout
import Game.Account.Bounces.Messages as Bounces
import Game.Models as Game


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Config msg -> Game.Model -> Msg -> Model -> UpdateResponse msg
update config game msg model =
    case msg of
        BouncesMsg msg ->
            onBounce config game msg model

        FinancesMsg msg ->
            onFinances config msg model

        DatabaseMsg msg ->
            onDatabase config game msg model

        NotificationsMsg msg ->
            onNotifications config game msg model

        Request data ->
            data
                |> receive
                |> Maybe.map (flip (updateRequest config game) model)
                |> Maybe.withDefault (Update.fromModel model)

        HandleLogout ->
            handleLogout config model

        HandleSetGateway cid ->
            handleSetGateway config game cid model

        HandleSetEndpoint mCid ->
            handleSetEndpoint config game mCid model

        HandleSetContext context ->
            handleSetContext config game context model

        HandleNewGateway cid ->
            handleNewGateway cid model

        HandleLogoutAndCrash error ->
            handleLogoutAndCrash config game error model

        HandleTutorialCompleted bool ->
            handleTutorialCompleted config game bool model

        HandleConnected ->
            handleConnected model

        HandleDisconnected ->
            handleDisconnected model



-- internals


handleSetGateway : Config msg -> Game.Model -> Servers.CId -> Model -> UpdateResponse msg
handleSetGateway config game cid model =
    Update.fromModel { model | activeGateway = Just cid }


handleSetEndpoint :
    Config msg
    -> Game.Model
    -> Maybe Servers.CId
    -> Model
    -> UpdateResponse msg
handleSetEndpoint config game cid model =
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
                        ensureValidContext config game { model | context = Gateway }
                    else
                        ensureValidContext config game model
            in
                ( model_, Cmd.none, dispatch )

        Nothing ->
            Update.fromModel model


handleSetContext : Config msg -> Game.Model -> Context -> Model -> UpdateResponse msg
handleSetContext config game context model =
    let
        model1 =
            { model | context = context }

        model_ =
            ensureValidContext config game model1
    in
        ( model_, Cmd.none, Dispatch.none )


onDatabase : Config msg -> Game.Model -> Database.Msg -> Model -> UpdateResponse msg
onDatabase config game msg model =
    Update.child
        { get = .database
        , set = (\database model -> { model | database = database })
        , toMsg = (DatabaseMsg >> config.toMsg)
        , update = (Database.update game)
        }
        msg
        model


onFinances : Config msg -> Finances.Msg -> Model -> UpdateResponse msg
onFinances config msg model =
    let
        config_ =
            financesConfig model.id config

        ( finances, cmd, dispatch ) =
            Finances.update config_ msg <| getFinances model

        model_ =
            setFinances finances model
    in
        ( model_, cmd, dispatch )


onNotifications : Config msg -> Game.Model -> Notifications.Msg -> Model -> UpdateResponse msg
onNotifications config game msg model =
    Update.child
        { get = .notifications
        , set = (\notifications model -> { model | notifications = notifications })
        , toMsg = (NotificationsMsg >> config.toMsg)
        , update = (Notifications.update game Notifications.Account)
        }
        msg
        model


handleLogout : Config msg -> Model -> UpdateResponse msg
handleLogout config model =
    let
        model_ =
            { model | logout = ToLanding }

        token =
            getToken model

        cmd =
            Logout.request token model.id config
                |> Cmd.map config.toMsg
    in
        ( model_, cmd, Dispatch.none )


handleTutorialCompleted : Config msg -> Game.Model -> Bool -> Model -> UpdateResponse msg
handleTutorialCompleted config game bool model =
    let
        model_ =
            { model | inTutorial = bool }
    in
        Update.fromModel model_


handleLogoutAndCrash : Config msg -> Game.Model -> Error -> Model -> UpdateResponse msg
handleLogoutAndCrash config game error model =
    let
        model_ =
            { model | logout = ToCrash error }

        token =
            getToken model

        cmd =
            Logout.request token model.id config
                |> Cmd.map config.toMsg
    in
        ( model_, cmd, Dispatch.none )


onBounce : Config msg -> Game.Model -> Bounces.Msg -> Model -> UpdateResponse msg
onBounce config game msg model =
    let
        ( bounces, cmd, dispatch ) =
            Bounces.update game msg model.bounces

        cmd_ =
            Cmd.map (BouncesMsg >> config.toMsg) cmd

        model_ =
            { model | bounces = bounces }
    in
        ( model_, cmd_, dispatch )


updateRequest : Config msg -> Game.Model -> Response -> Model -> UpdateResponse msg
updateRequest config game response model =
    case response of
        _ ->
            Update.fromModel model


ensureValidContext : Config msg -> Game.Model -> Model -> Model
ensureValidContext config game model =
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


handleNewGateway : Servers.CId -> Model -> UpdateResponse msg
handleNewGateway cid model =
    model
        |> insertGateway cid
        |> Update.fromModel


handleConnected : Model -> UpdateResponse msg
handleConnected model =
    let
        dispatch =
            Dispatch.websocket <|
                Ws.Join (AccountChannel model.id) Nothing
    in
        ( model, Cmd.none, dispatch )


handleDisconnected : Model -> UpdateResponse msg
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
