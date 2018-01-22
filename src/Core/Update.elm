module Core.Update exposing (update)

import Utils.React as React exposing (React)
import Events.Handler as Events
import Landing.Messages as Landing
import Landing.Update as Landing
import Driver.Websocket.Messages as Ws
import Driver.Websocket.Models as Ws
import Driver.Websocket.Update as Ws
import Game.Messages as Game
import Game.Data as GameD
import Game.Models as Game
import Game.Meta.Models as Meta
import Game.Meta.Messages as Meta
import Game.Update as Game
import Setup.Messages as Setup
import Setup.Update as Setup
import OS.Messages as OS
import OS.Update as OS
import OS.SessionManager.WindowManager.Messages as WM
import OS.SessionManager.Messages as SM
import Apps.Messages as Apps
import Apps.TaskManager.Messages as TaskManager
import Core.Error as Error
import Core.Config exposing (..)
import Core.Flags as Flags exposing (Flags)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Messages exposing (..)
import Core.Models exposing (..)
import Core.Subscribers as Subscribers


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (onDebug model received msg) of
        BatchMsg msgs ->
            case msgs of
                [ msg ] ->
                    update msg model

                msg :: msgs ->
                    -- this will actually blow the stack when dispatching many
                    -- things, but we shouldn't dispatch more than 3 messages,
                    -- so whatever
                    let
                        ( model0, cmd0 ) =
                            update msg model

                        ( model_, cmd1 ) =
                            update (BatchMsg msgs) model0
                    in
                        ( model_, Cmd.batch [ cmd0, cmd1 ] )

                [] ->
                    ( model, Cmd.none )

        HandleBoot id username token ->
            let
                model_ =
                    connect id username token model
            in
                ( model_, Cmd.none )

        HandleShutdown ->
            let
                model_ =
                    logout model
            in
                ( model_, Cmd.none )

        HandleCrash ( code, message ) ->
            let
                model_ =
                    crash code message model
            in
                ( model_, Cmd.none )

        HandlePlay ->
            let
                ( state, cmd, dispatch ) =
                    setupToPlay model.state

                model_ =
                    { model | state = state }
            in
                dispatcher model_ cmd dispatch

        HandleEvent channel value ->
            case Events.handler eventsConfig channel value of
                Ok msg ->
                    ( model, React.toCmd <| React.msg msg )

                Err error ->
                    always ( model, Cmd.none ) <|
                        Debug.log (Events.report error) ""

        LoadingEnd z ->
            let
                model_ =
                    { model | windowLoaded = True }
            in
                ( model_, Cmd.none )

        _ ->
            updateState msg model



-- internals


updateState : Msg -> Model -> ( Model, Cmd Msg )
updateState msg ({ state } as model) =
    case state of
        Home stateModel ->
            updateHome msg model stateModel

        Setup stateModel ->
            updateSetup msg model stateModel

        Play stateModel ->
            updatePlay msg model stateModel

        Panic _ _ ->
            ( model, Cmd.none )


updateHome : Msg -> Model -> HomeModel -> ( Model, Cmd Msg )
updateHome msg model stateModel =
    case msg of
        HandleConnected ->
            let
                ( modelLogin, cmdLogin, dispatch ) =
                    login model

                -- not tail recursive, but should only do a single recursion
                ( modelLogin_, cmdLogin_ ) =
                    dispatcher modelLogin cmdLogin dispatch

                ( model_, cmdNext ) =
                    updateState msg modelLogin_

                cmd =
                    Cmd.batch [ cmdLogin_, cmdNext ]
            in
                ( model_, cmd )

        WebsocketMsg msg ->
            case stateModel.websocket of
                Just websocket ->
                    let
                        ( websocket_, cmd ) =
                            websocket
                                |> Ws.update (websocketConfig model.flags) msg
                                |> Tuple.mapSecond React.toCmd

                        stateModel_ =
                            { stateModel | websocket = Just websocket_ }

                        model_ =
                            { model | state = Home stateModel_ }
                    in
                        ( model_, cmd )

                Nothing ->
                    ( model, Cmd.none )

        LandingMsg msg ->
            updateLanding msg model stateModel

        _ ->
            ( model, Cmd.none )


updateSetup : Msg -> Model -> SetupModel -> ( Model, Cmd Msg )
updateSetup msg model stateModel =
    case msg of
        WebsocketMsg msg ->
            updateSetupWS model.flags msg stateModel
                |> finishSetupUpdate model

        SetupMsg msg ->
            updateSetupSetup msg stateModel
                |> finishSetupUpdate model

        GameMsg msg ->
            updateSetupGame msg stateModel
                |> finishSetupUpdate model

        _ ->
            ( model, Cmd.none )


updateSetupWS :
    Flags
    -> Ws.Msg
    -> SetupModel
    -> ( SetupModel, Cmd Msg )
updateSetupWS flags msg stateModel =
    let
        ( websocket, cmd ) =
            stateModel.websocket
                |> Ws.update (websocketConfig flags) msg
                |> Tuple.mapSecond React.toCmd

        stateModel_ =
            { stateModel | websocket = websocket }
    in
        ( stateModel_, cmd )


updateSetupSetup : Setup.Msg -> SetupModel -> ( SetupModel, Cmd Msg )
updateSetupSetup msg stateModel =
    let
        config =
            setupConfig
                stateModel.game.account.id
                stateModel.game.account.mainframe
                stateModel.game.flags

        ( setup, react ) =
            Setup.update config msg stateModel.setup

        stateModel_ =
            { stateModel | setup = setup }
    in
        ( stateModel_, React.toCmd react )


updateSetupGame : Game.Msg -> SetupModel -> ( SetupModel, Cmd Msg )
updateSetupGame msg stateModel =
    let
        ( game, cmd ) =
            stateModel.game
                |> Game.update gameConfig msg
                |> Tuple.mapSecond React.toCmd

        stateModel_ =
            { stateModel | game = game }
    in
        ( stateModel_, cmd )


finishSetupUpdate : Model -> ( SetupModel, Cmd Msg ) -> ( Model, Cmd Msg )
finishSetupUpdate model ( stateModel, cmd ) =
    ( { model | state = Setup stateModel }, cmd )


updatePlay : Msg -> Model -> PlayModel -> ( Model, Cmd Msg )
updatePlay msg model stateModel =
    case msg of
        WebsocketMsg msg ->
            updatePlayWS model.flags msg stateModel
                |> finishPlayUpdate model

        OSMsg msg ->
            updatePlayOS msg stateModel
                |> finishPlayUpdate model

        GameMsg msg ->
            updatePlayGame msg stateModel
                |> finishPlayUpdate model

        _ ->
            ( model, Cmd.none )


updatePlayWS : Flags -> Ws.Msg -> PlayModel -> ( PlayModel, Cmd Msg, Dispatch )
updatePlayWS flags msg stateModel =
    let
        ( websocket, cmd ) =
            stateModel.websocket
                |> Ws.update (websocketConfig flags) msg
                |> Tuple.mapSecond React.toCmd

        stateModel_ =
            { stateModel | websocket = websocket }
    in
        ( stateModel_, cmd, Dispatch.none )


updatePlayOS : OS.Msg -> PlayModel -> ( PlayModel, Cmd Msg, Dispatch )
updatePlayOS msg stateModel =
    case GameD.fromGateway stateModel.game of
        Just data ->
            let
                activeServer =
                    case Game.getActiveServer stateModel.game of
                        Just ( _, activeServer ) ->
                            activeServer

                        Nothing ->
                            "Player has no active Server"
                                |> Error.astralProj
                                |> uncurry Native.Panic.crash

                lastTick =
                    stateModel.game
                        |> Game.getMeta
                        |> Meta.getLastTick

                config =
                    osConfig account story lastTick activeServer

                account =
                    Game.getAccount stateModel.game

                story =
                    Game.getStory stateModel.game

                ( os, cmd, dispatch ) =
                    OS.update config data msg stateModel.os

                stateModel_ =
                    { stateModel | os = os }
            in
                ( stateModel_, cmd, dispatch )

        Nothing ->
            ( stateModel, Cmd.none, Dispatch.none )


updatePlayGame : Game.Msg -> PlayModel -> ( PlayModel, Cmd Msg, Dispatch )
updatePlayGame msg stateModel =
    let
        ( game, cmd ) =
            stateModel.game
                |> Game.update gameConfig msg
                |> Tuple.mapSecond React.toCmd

        stateModel_ =
            { stateModel | game = game }
    in
        ( stateModel_, cmd, Dispatch.none )


finishPlayUpdate : Model -> ( PlayModel, Cmd Msg, Dispatch ) -> ( Model, Cmd Msg )
finishPlayUpdate model ( stateModel, cmd, dispatch ) =
    let
        model_ =
            { model | state = Play stateModel }
    in
        dispatcher model_ cmd dispatch


updateLanding :
    Landing.Msg
    -> Model
    -> HomeModel
    -> ( Model, Cmd Msg )
updateLanding msg model ({ landing } as stateModel) =
    let
        ( landing_, react ) =
            Landing.update (landingConfig model.windowLoaded model.flags)
                msg
                landing

        stateModel_ =
            { stateModel | landing = landing_ }

        model_ =
            { model | state = Home stateModel_ }
    in
        dispatcher model_ (React.toCmd react) Dispatch.none



-- dispatcher code


isDev : Model -> Bool
isDev =
    getFlags >> Flags.isDev


onDebug : Model -> (a -> a) -> a -> a
onDebug model fun a =
    if isDev model then
        fun a
    else
        a


received : Msg -> Msg
received msg =
    case msg of
        -- ignored messages
        GameMsg (Game.MetaMsg (Meta.Tick _)) ->
            msg

        OSMsg (OS.SessionManagerMsg (SM.WindowManagerMsg _ (WM.OnDragBy _))) ->
            msg

        OSMsg (OS.SessionManagerMsg (SM.WindowManagerMsg _ (WM.DragMsg _))) ->
            msg

        OSMsg (OS.SessionManagerMsg (SM.WindowManagerMsg _ (WM.AppMsg _ _ (Apps.TaskManagerMsg (TaskManager.Tick _))))) ->
            msg

        _ ->
            Debug.log "▶ Message" msg


sent : a -> a
sent =
    -- uncomment this line to see sent messages
    --Debug.log "◀ Message"
    identity


dispatcher : Model -> Cmd Msg -> Dispatch -> ( Model, Cmd Msg )
dispatcher model cmd dispatch =
    dispatch
        |> Subscribers.dispatch
        |> List.foldl (sent >> reducer) ( model, cmd )


reducer : Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
reducer msg ( model, cmd ) =
    let
        ( model_, cmd_ ) =
            update msg model
    in
        ( model_, Cmd.batch [ cmd, cmd_ ] )
