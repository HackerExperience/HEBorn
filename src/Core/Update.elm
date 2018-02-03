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
            ( connect id username token model, Cmd.none )

        HandleShutdown ->
            ( logout model, Cmd.none )

        HandleCrash ( code, message ) ->
            ( crash code message model, Cmd.none )

        HandlePlay ->
            let
                ( state, cmd ) =
                    setupToPlay model.state
            in
                ( { model | state = state }, cmd )

        HandleEvent channel value ->
            case Events.handler eventsConfig channel value of
                Ok msg ->
                    update msg model

                Err error ->
                    always ( model, Cmd.none ) <|
                        Debug.log (Events.report error) ""

        LoadingEnd z ->
            ( { model | windowLoaded = True }, Cmd.none )

        MenuMsg msg ->
            let
                ( menuModel, menuCmd ) =
                    ContextMenu.update msg model.contextMenu

                cmd =
                    Cmd.map MenuMsg menuCmd
            in
                ( { model | contextMenu = menuModel }
                , cmd
                )

        _ ->
            dispatch <| updateState msg model



-- internals


dispatch : ( Model, React Msg ) -> ( Model, Cmd Msg )
dispatch ( model, react ) =
    case React.split react of
        ( Just msg, cmd ) ->
            case update msg model of
                ( model, cmd2 ) ->
                    ( model, Cmd.batch [ cmd, cmd2 ] )

        ( Nothing, cmd ) ->
            ( model, cmd )


updateState : Msg -> Model -> ( Model, React Msg )
updateState msg ({ state } as model) =
    case state of
        Home stateModel ->
            updateHome msg model stateModel

        Setup stateModel ->
            updateSetup msg model stateModel

        Play stateModel ->
            updatePlay msg model stateModel

        Panic _ _ ->
            ( model, React.none )


updateHome : Msg -> Model -> HomeModel -> ( Model, React Msg )
updateHome msg model stateModel =
    case msg of
        HandleConnected ->
            let
                ( modelLogin, cmdLogin ) =
                    login model

                ( model_, reactNext ) =
                    updateState msg modelLogin
            in
                ( model_, React.addCmd cmdLogin reactNext )

        WebsocketMsg msg ->
            case stateModel.websocket of
                Just websocket ->
                    let
                        ( websocket_, react ) =
                            Ws.update (websocketConfig model.flags)
                                msg
                                websocket

                        stateModel_ =
                            { stateModel | websocket = Just websocket_ }
                    in
                        ( { model | state = Home stateModel_ }, react )

                Nothing ->
                    ( model, React.none )

        LandingMsg msg ->
            updateLanding msg model stateModel

        _ ->
            ( model, React.none )


updateSetup : Msg -> Model -> SetupModel -> ( Model, React Msg )
updateSetup msg model stateModel =
    case msg of
        WebsocketMsg msg ->
            stateModel
                |> updateSetupWS model.flags msg
                |> finishSetupUpdate model

        SetupMsg msg ->
            stateModel
                |> updateSetupSetup msg
                |> finishSetupUpdate model

        GameMsg msg ->
            stateModel
                |> updateSetupGame msg
                |> finishSetupUpdate model

        _ ->
            ( model, React.none )


updateSetupWS :
    Flags
    -> Ws.Msg
    -> SetupModel
    -> ( SetupModel, React Msg )
updateSetupWS flags msg stateModel =
    let
        ( websocket, react ) =
            Ws.update (websocketConfig flags) msg stateModel.websocket
    in
        ( { stateModel | websocket = websocket }, react )


updateSetupSetup : Setup.Msg -> SetupModel -> ( SetupModel, React Msg )
updateSetupSetup msg stateModel =
    let
        config =
            setupConfig
                stateModel.game.account.id
                stateModel.game.account.mainframe
                stateModel.game.flags

        ( setup, react ) =
            Setup.update config msg stateModel.setup
    in
        ( { stateModel | setup = setup }, react )


updateSetupGame : Game.Msg -> SetupModel -> ( SetupModel, React Msg )
updateSetupGame msg stateModel =
    let
        ( game, react ) =
            Game.update gameConfig msg stateModel.game
    in
        ( { stateModel | game = game }, react )


finishSetupUpdate : Model -> ( SetupModel, a ) -> ( Model, a )
finishSetupUpdate model ( stateModel, react ) =
    ( { model | state = Setup stateModel }, react )


updatePlay : Msg -> Model -> PlayModel -> ( Model, React Msg )
updatePlay msg model stateModel =
    case msg of
        WebsocketMsg msg ->
            stateModel
                |> updatePlayWS model.flags msg
                |> finishPlayUpdate model

        OSMsg msg ->
            model
                |> updatePlayOS msg stateModel
                |> finishPlayUpdate model

        GameMsg msg ->
            stateModel
                |> updatePlayGame msg
                |> finishPlayUpdate model

        _ ->
            ( model, React.none )


updatePlayWS : Flags -> Ws.Msg -> PlayModel -> ( PlayModel, React Msg )
updatePlayWS flags msg stateModel =
    let
        ( websocket, react ) =
            Ws.update (websocketConfig flags) msg stateModel.websocket
    in
        ( { stateModel | websocket = websocket }, react )


updatePlayOS : OS.Msg -> PlayModel -> Model -> ( PlayModel, React Msg )
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
                in
                    ( { state | os = os_ }, react )

            _ ->
                ( state, React.none )


updatePlayGame : Game.Msg -> PlayModel -> ( PlayModel, React Msg )
updatePlayGame msg stateModel =
    let
        ( game, react ) =
            Game.update gameConfig msg stateModel.game
    in
        ( { stateModel | game = game }, react )


finishPlayUpdate : Model -> ( PlayModel, a ) -> ( Model, a )
finishPlayUpdate model ( stateModel, react ) =
    ( { model | state = Play stateModel }, react )


updateLanding :
    Landing.Msg
    -> Model
    -> HomeModel
    -> ( Model, React Msg )
updateLanding msg model ({ landing } as stateModel) =
    let
        ( landing_, react ) =
            Landing.update (landingConfig model.windowLoaded model.flags)
                msg
                landing

        stateModel_ =
            { stateModel | landing = landing_ }
    in
        ( { model | state = Home stateModel_ }, react )



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
        BatchMsg [] ->
            Debug.log "☹ Empty BatchMsg" msg

        -- ignored messages
        BatchMsg _ ->
            msg

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
