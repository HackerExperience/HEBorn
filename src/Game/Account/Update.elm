module Game.Account.Update exposing (update)

import Utils.React as React exposing (React)
import Core.Error as Error exposing (Error)
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
import Game.Account.Bounces.Messages as Bounces
import Game.Account.Requests.Logout exposing (logoutRequest)
import Game.Account.Config exposing (..)
import Game.Account.Messages exposing (..)
import Game.Account.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


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
            handleConnected config model

        HandleDisconnected ->
            handleDisconnected config model



-- internals


handleSetGateway : Config msg -> Servers.CId -> Model -> UpdateResponse msg
handleSetGateway config cid model =
    ( { model | activeGateway = Just cid }
    , React.none
    )


handleSetEndpoint :
    Config msg
    -> Maybe Servers.CId
    -> Model
    -> UpdateResponse msg
handleSetEndpoint config cid model =
    -- this looks like wrong
    case getGateway model of
        Just gateway ->
            let
                react =
                    case getGateway model of
                        Just gatewayId ->
                            React.msg <| config.onSetEndpoint gatewayId cid

                        Nothing ->
                            React.none

                model_ =
                    if cid == Nothing then
                        config.fallToGateway (fallToGateway model)
                    else
                        config.fallToGateway (fallToGateway model)
            in
                ( model_, react )

        Nothing ->
            ( model, React.none )


handleSetContext : Config msg -> Context -> Model -> UpdateResponse msg
handleSetContext config context model =
    let
        model1 =
            { model | context = context }

        model_ =
            config.fallToGateway (fallToGateway model1)
    in
        ( model_, React.none )


onDatabase : Config msg -> Database.Msg -> Model -> UpdateResponse msg
onDatabase config msg model =
    let
        config_ =
            databaseConfig config

        ( database, react ) =
            Database.update config_ msg <| getDatabase model

        model_ =
            setDatabase database model
    in
        ( model_, react )


onFinances : Config msg -> Finances.Msg -> Model -> UpdateResponse msg
onFinances config msg model =
    let
        config_ =
            financesConfig model.id config

        ( finances, react ) =
            Finances.update config_ msg <| getFinances model

        model_ =
            setFinances finances model
    in
        ( model_, react )


onNotifications : Config msg -> Notifications.Msg -> Model -> UpdateResponse msg
onNotifications config msg model =
    let
        config_ =
            notificationsConfig config

        ( notifications, react ) =
            Notifications.update config_ msg <| getNotifications model

        model_ =
            setNotifications notifications model
    in
        ( model_, react )


handleLogout : Config msg -> Model -> UpdateResponse msg
handleLogout config model =
    let
        model_ =
            { model | logout = ToLanding }

        token =
            getToken model

        react =
            config
                |> logoutRequest token model.id
                |> Cmd.map (always <| config.batchMsg [])
                |> React.cmd
    in
        ( model_, react )


handleTutorialCompleted : Config msg -> Bool -> Model -> UpdateResponse msg
handleTutorialCompleted config bool model =
    ( { model | inTutorial = bool }
    , React.none
    )


handleLogoutAndCrash : Config msg -> Error -> Model -> UpdateResponse msg
handleLogoutAndCrash config error model =
    let
        model_ =
            { model | logout = ToCrash error }

        token =
            getToken model

        react =
            config
                |> logoutRequest token model.id
                |> Cmd.map (always <| config.batchMsg [])
                |> React.cmd
    in
        ( model_, react )


onBounces : Config msg -> Bounces.Msg -> Model -> UpdateResponse msg
onBounces config msg model =
    let
        config_ =
            bouncesConfig config

        ( bounces, react ) =
            Bounces.update config_ msg <| getBounces model

        model_ =
            setBounces bounces model
    in
        ( model_, react )


handleNewGateway : Servers.CId -> Model -> UpdateResponse msg
handleNewGateway cid model =
    ( insertGateway cid model, React.none )


handleConnected : Config msg -> Model -> UpdateResponse msg
handleConnected config model =
    ( model, React.msg <| config.onConnected (model.id) )


handleDisconnected : Config msg -> Model -> UpdateResponse msg
handleDisconnected config model =
    let
        react =
            case model.logout of
                ToLanding ->
                    React.msg <| config.onDisconnected

                ToCrash error ->
                    React.msg <| config.onError error

                _ ->
                    React.none
    in
        ( model, react )
