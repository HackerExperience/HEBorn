module Core.Update exposing (update)

import ContextMenu
import Utils.React as React exposing (React)
import Events.Handler as Events
import Landing.Messages as Landing
import Landing.Update as Landing
import Driver.Websocket.Messages as Ws
import Driver.Websocket.Update as Ws
import Game.Messages as Game
import Game.Models as Game
import Game.Meta.Models as Meta
import Game.Meta.Messages as Meta
import Game.Update as Game
import Game.Account.Models as Account
import Setup.Messages as Setup
import Setup.Update as Setup
import OS.Messages as OS
import OS.Update as OS
import OS.WindowManager.Messages as WindowManager
import Apps.TaskManager.Messages as TaskManager
import Core.Config exposing (..)
import Core.Flags as Flags exposing (Flags)
import Core.Messages exposing (..)
import Core.Models exposing (..)


-- TODO: Use onSth pattern


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
                ( state, cmd ) =
                    setupToPlay model.state
            in
                ( { model | state = state }, cmd )

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

        MenuMsg msg ->
            let
                ( menuModel, menuCmd ) =
                    ContextMenu.update msg model.contextMenu

                model_ =
                    { model | contextMenu = menuModel }

                cmd =
                    Cmd.map MenuMsg menuCmd
            in
                ( model_, cmd )

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
                ( modelLogin, cmdLogin ) =
                    login model

                ( model_, cmdNext ) =
                    updateState msg modelLogin

                cmd =
                    Cmd.batch [ cmdLogin, cmdNext ]
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
            model
                |> updatePlayOS msg stateModel
                |> finishPlayUpdate model

        GameMsg msg ->
            updatePlayGame msg stateModel
                |> finishPlayUpdate model

        _ ->
            ( model, Cmd.none )


updatePlayWS : Flags -> Ws.Msg -> PlayModel -> ( PlayModel, Cmd Msg )
updatePlayWS flags msg stateModel =
    let
        ( websocket, cmd ) =
            stateModel.websocket
                |> Ws.update (websocketConfig flags) msg
                |> Tuple.mapSecond React.toCmd

        stateModel_ =
            { stateModel | websocket = websocket }
    in
        ( stateModel_, cmd )


updatePlayOS : OS.Msg -> PlayModel -> Model -> ( PlayModel, Cmd Msg )
updatePlayOS msg ({ game, os } as state) { contextMenu } =
    let
        volatile_ =
            ( Game.getGateway game
            , Game.getActiveServer game
            )

        ctx =
            Account.getContext <| Game.getAccount game
    in
        case volatile_ of
            ( Just gtw, Just srv ) ->
                let
                    lastTick =
                        game
                            |> Game.getMeta
                            |> Meta.getLastTick

                    config =
                        osConfig game contextMenu srv ctx gtw

                    ( os_, react ) =
                        OS.update config msg os

                    state_ =
                        { state | os = os_ }
                in
                    ( state_, React.toCmd react )

            _ ->
                ( state, Cmd.none )


updatePlayGame : Game.Msg -> PlayModel -> ( PlayModel, Cmd Msg )
updatePlayGame msg stateModel =
    let
        ( game, cmd ) =
            stateModel.game
                |> Game.update gameConfig msg
                |> Tuple.mapSecond React.toCmd

        stateModel_ =
            { stateModel | game = game }
    in
        ( stateModel_, cmd )


finishPlayUpdate : Model -> ( PlayModel, Cmd Msg ) -> ( Model, Cmd Msg )
finishPlayUpdate model ( stateModel, cmd ) =
    ( { model | state = Play stateModel }, cmd )


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
        ( model_, (React.toCmd react) )



-- code


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

        OSMsg (OS.WindowManagerMsg (WindowManager.StartDrag _)) ->
            msg

        OSMsg (OS.WindowManagerMsg (WindowManager.Dragging _)) ->
            msg

        OSMsg (OS.WindowManagerMsg WindowManager.StopDrag) ->
            msg

        OSMsg (OS.WindowManagerMsg (WindowManager.AppMsg _ (WindowManager.TaskManagerMsg (TaskManager.Tick _)))) ->
            msg

        _ ->
            Debug.log "▶ Message" msg
