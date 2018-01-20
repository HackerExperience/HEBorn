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
import Game.Account.Notifications.Models as Notifications
import Game.Account.Notifications.Messages as Notifications
import Game.Account.Notifications.Update as Notifications
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


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        BouncesMsg msg ->
            onBounces config msg model

        FinancesMsg msg ->
            onFinances config msg model

        DatabaseMsg msg ->
            onDatabase config msg model

        NotificationsMsg msg ->
            onNotifications config msg model

        Request data ->
            data
                |> receive
                |> Maybe.map (flip (updateRequest config) model)
                |> Maybe.withDefault (Update.fromModel model)

        HandleLogout ->
            handleLogout config model

        HandleSetGateway cid ->
            handleSetGateway config cid model

        HandleSetEndpoint mCid ->
            handleSetEndpoint config mCid model

        HandleSetContext context ->
            handleSetContext config context model

        HandleNewGateway cid ->
            handleNewGateway cid model

        HandleLogoutAndCrash error ->
            handleLogoutAndCrash config error model

        HandleTutorialCompleted bool ->
            handleTutorialCompleted config bool model

        HandleConnected ->
            handleConnected model

        HandleDisconnected ->
            handleDisconnected model



-- internals


handleSetGateway : Config msg -> Servers.CId -> Model -> UpdateResponse msg
handleSetGateway config cid model =
    Update.fromModel { model | activeGateway = Just cid }


handleSetEndpoint :
    Config msg
    -> Maybe Servers.CId
    -> Model
    -> UpdateResponse msg
handleSetEndpoint config cid model =
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
                        config.fallToGateway (fallToGateway model)
                    else
                        config.fallToGateway (fallToGateway model)
            in
                ( model_, Cmd.none, dispatch )

        Nothing ->
            Update.fromModel model


handleSetContext : Config msg -> Context -> Model -> UpdateResponse msg
handleSetContext config context model =
    let
        model1 =
            { model | context = context }

        model_ =
            config.fallToGateway (fallToGateway model1)
    in
        ( model_, Cmd.none, Dispatch.none )


onDatabase : Config msg -> Database.Msg -> Model -> UpdateResponse msg
onDatabase config msg model =
    let
        config_ =
            databaseConfig config

        ( database, cmd, dispatch ) =
            Database.update config_ msg <| getDatabase model

        model_ =
            setDatabase database model
    in
        ( model_, cmd, dispatch )


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


onNotifications : Config msg -> Notifications.Msg -> Model -> UpdateResponse msg
onNotifications config msg model =
    let
        config_ =
            notificationsConfig config

        ( notifications, cmd ) =
            Notifications.update config_ msg <| getNotifications model

        model_ =
            setNotifications notifications model
    in
        ( model_, cmd, Dispatch.none )


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


handleTutorialCompleted : Config msg -> Bool -> Model -> UpdateResponse msg
handleTutorialCompleted config bool model =
    let
        model_ =
            { model | inTutorial = bool }
    in
        Update.fromModel model_


handleLogoutAndCrash : Config msg -> Error -> Model -> UpdateResponse msg
handleLogoutAndCrash config error model =
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


onBounces : Config msg -> Bounces.Msg -> Model -> UpdateResponse msg
onBounces config msg model =
    let
        config_ =
            bouncesConfig config

        ( bounces, cmd, dispatch ) =
            Bounces.update config_ msg <| getBounces model

        model_ =
            setBounces bounces model
    in
        ( model_, cmd, dispatch )


updateRequest : Config msg -> Response -> Model -> UpdateResponse msg
updateRequest config response model =
    case response of
        _ ->
            Update.fromModel model


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
