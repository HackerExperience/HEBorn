module Core.Update exposing (update)

import Core.Messages exposing (..)
import Core.Models exposing (..)
import Core.Subscribers as Subscribers
import Core.Dispatch as Dispatch exposing (Dispatch)
import Driver.Websocket.Messages as Ws
import Driver.Websocket.Models as Ws
import Driver.Websocket.Update as Ws
import Driver.Websocket.Reports exposing (..)
import Events.Events as Events exposing (..)
import Landing.Messages as Landing
import Landing.Update as Landing
import Game.Data as Game
import Game.Messages as Game
import Game.Models as Game
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (onDebug model received msg) of
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
                        ( websocket_, cmd, dispatch ) =
                            updateWebsocket msg websocket

                        stateModel_ =
                            { stateModel | websocket = Just websocket_ }

                        model_ =
                            { model | state = Home stateModel_ }
                    in
                        dispatcher model_ cmd dispatch

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
            updateSetupWS msg stateModel
                |> finishSetupUpdate model

        SetupMsg msg ->
            updateSetupSetup msg stateModel
                |> finishSetupUpdate model

        GameMsg msg ->
            updateSetupGame msg stateModel
                |> finishSetupUpdate model

        _ ->
            ( model, Cmd.none )


updateSetupWS : Ws.Msg -> SetupModel -> ( SetupModel, Cmd Msg, Dispatch )
updateSetupWS msg stateModel =
    let
        ( websocket, cmd, dispatch ) =
            updateWebsocket msg stateModel.websocket

        stateModel_ =
            { stateModel | websocket = websocket }
    in
        ( stateModel_, cmd, dispatch )


updateSetupSetup : Setup.Msg -> SetupModel -> ( SetupModel, Cmd Msg, Dispatch )
updateSetupSetup msg stateModel =
    let
        ( setup, cmd, dispatch ) =
            Setup.update stateModel.game msg stateModel.setup

        stateModel_ =
            { stateModel | setup = setup }

        cmd_ =
            Cmd.map SetupMsg cmd
    in
        ( stateModel_, cmd_, dispatch )


updateSetupGame : Game.Msg -> SetupModel -> ( SetupModel, Cmd Msg, Dispatch )
updateSetupGame msg stateModel =
    let
        ( game, cmd, dispatch ) =
            updateGame msg stateModel.game

        stateModel_ =
            { stateModel | game = game }
    in
        ( stateModel_, cmd, dispatch )


finishSetupUpdate : Model -> ( SetupModel, Cmd Msg, Dispatch ) -> ( Model, Cmd Msg )
finishSetupUpdate model ( stateModel, cmd, dispatch ) =
    let
        model_ =
            { model | state = Setup stateModel }
    in
        dispatcher model_ cmd dispatch


updatePlay : Msg -> Model -> PlayModel -> ( Model, Cmd Msg )
updatePlay msg model stateModel =
    case msg of
        WebsocketMsg msg ->
            updatePlayWS msg stateModel
                |> finishPlayUpdate model

        OSMsg msg ->
            updatePlayOS msg stateModel
                |> finishPlayUpdate model

        GameMsg msg ->
            updatePlayGame msg stateModel
                |> finishPlayUpdate model

        _ ->
            ( model, Cmd.none )


updatePlayWS : Ws.Msg -> PlayModel -> ( PlayModel, Cmd Msg, Dispatch )
updatePlayWS msg stateModel =
    let
        ( websocket, cmd, dispatch ) =
            updateWebsocket msg stateModel.websocket

        stateModel_ =
            { stateModel | websocket = websocket }
    in
        ( stateModel_, cmd, dispatch )


updatePlayOS : OS.Msg -> PlayModel -> ( PlayModel, Cmd Msg, Dispatch )
updatePlayOS msg stateModel =
    case Game.fromGateway stateModel.game of
        Just data ->
            let
                ( os, cmd, dispatch ) =
                    OS.update data msg stateModel.os

                stateModel_ =
                    { stateModel | os = os }

                cmd_ =
                    Cmd.map OSMsg cmd
            in
                ( stateModel_, cmd_, dispatch )

        Nothing ->
            ( stateModel, Cmd.none, Dispatch.none )


updatePlayGame : Game.Msg -> PlayModel -> ( PlayModel, Cmd Msg, Dispatch )
updatePlayGame msg stateModel =
    let
        ( game, cmd, dispatch ) =
            updateGame msg stateModel.game

        stateModel_ =
            { stateModel | game = game }
    in
        ( stateModel_, cmd, dispatch )


finishPlayUpdate : Model -> ( PlayModel, Cmd Msg, Dispatch ) -> ( Model, Cmd Msg )
finishPlayUpdate model ( stateModel, cmd, dispatch ) =
    let
        model_ =
            { model | state = Play stateModel }
    in
        dispatcher model_ cmd dispatch


stateAndThen :
    (a -> ( a, Cmd b, Dispatch ))
    -> ( a, Cmd b, Dispatch )
    -> ( a, Cmd b, Dispatch )
stateAndThen apply ( stateModel, cmd0, dispatch0 ) =
    let
        ( stateModel_, cmd1, dispatch1 ) =
            apply stateModel

        cmd =
            Cmd.batch [ cmd0, cmd1 ]

        dispatch =
            Dispatch.batch [ dispatch0, dispatch1 ]
    in
        ( stateModel_, cmd, dispatch )


updateLanding :
    Landing.Msg
    -> Model
    -> HomeModel
    -> ( Model, Cmd Msg )
updateLanding msg model ({ landing } as stateModel) =
    let
        ( landing_, cmd, dispatch ) =
            Landing.update model msg landing

        cmd_ =
            Cmd.map LandingMsg cmd

        stateModel_ =
            { stateModel | landing = landing_ }

        model_ =
            { model | state = Home stateModel_ }
    in
        dispatcher model_ cmd_ dispatch


updateGame : Game.Msg -> Game.Model -> ( Game.Model, Cmd Msg, Dispatch )
updateGame msg model =
    let
        ( model_, cmd, dispatch ) =
            Game.update msg model

        cmd_ =
            Cmd.map GameMsg cmd
    in
        ( model_, cmd_, dispatch )


updateWebsocket : Ws.Msg -> Ws.Model -> ( Ws.Model, Cmd Msg, Dispatch )
updateWebsocket msg model =
    let
        ( model_, cmd, dispatch ) =
            Ws.update msg model

        cmd_ =
            Cmd.map WebsocketMsg cmd
    in
        ( model_, cmd_, dispatch )



-- dispatcher code


isDev : Model -> Bool
isDev model =
    let
        { version } =
            getConfig model
    in
        -- make this function return False to test the game on production mode
        version == "dev"


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
