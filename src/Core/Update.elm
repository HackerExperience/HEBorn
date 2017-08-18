module Core.Update exposing (update)

import Core.Messages exposing (..)
import Core.Models exposing (..)
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
import Setup.Update as Setup
import OS.Messages as OS
import OS.Update as OS
import OS.SessionManager.WindowManager.Messages as WM
import OS.SessionManager.Messages as SM


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    -- DONE
    case (onDebug model received msg) of
        Boot id username token firstRun ->
            let
                model_ =
                    connect id username token firstRun model
            in
                ( model_, Cmd.none )

        Shutdown ->
            let
                model_ =
                    logout model
            in
                ( model_, Cmd.none )

        LoadingEnd z ->
            let
                model_ =
                    { model | windowLoaded = True }
            in
                ( model_, Cmd.none )

        FinishSetup ->
            let
                ( state, cmd, dispatch ) =
                    setupToPlay model.state

                model_ =
                    { model | state = state }
            in
                dispatcher model_ cmd dispatch

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


updateHome : Msg -> Model -> HomeModel -> ( Model, Cmd Msg )
updateHome msg model stateModel =
    case msg of
        WebsocketMsg (Ws.Broadcast (Report (Connected _))) ->
            -- trap used for login
            let
                ( modelLogin, cmdLogin, dispatch ) =
                    login model

                -- not tail recursive, but should
                -- only do a single recursion
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
    -- DONE
    case msg of
        WebsocketMsg (Ws.Broadcast event) ->
            updateEvent event model

        WebsocketMsg msg ->
            let
                ( websocket, cmd, dispatch ) =
                    updateWebsocket msg stateModel.websocket

                stateModel_ =
                    { stateModel | websocket = websocket }

                model_ =
                    { model | state = Setup stateModel_ }
            in
                dispatcher model_ cmd dispatch

        SetupMsg msg ->
            let
                ( setup, cmd, dispatch ) =
                    Setup.update stateModel.game msg stateModel.setup

                stateModel_ =
                    { stateModel | setup = setup }

                model_ =
                    { model | state = Setup stateModel_ }

                cmd_ =
                    Cmd.map SetupMsg cmd
            in
                dispatcher model_ cmd_ dispatch

        GameMsg msg ->
            let
                ( game, cmd, dispatch ) =
                    updateGame msg stateModel.game

                stateModel_ =
                    { stateModel | game = game }

                model_ =
                    { model | state = Setup stateModel_ }
            in
                dispatcher model_ cmd dispatch

        _ ->
            ( model, Cmd.none )


updatePlay : Msg -> Model -> PlayModel -> ( Model, Cmd Msg )
updatePlay msg model stateModel =
    case msg of
        WebsocketMsg (Ws.Broadcast event) ->
            updateEvent event model

        WebsocketMsg msg ->
            let
                ( websocket, cmd, dispatch ) =
                    updateWebsocket msg stateModel.websocket

                stateModel_ =
                    { stateModel | websocket = websocket }

                model_ =
                    { model | state = Play stateModel_ }
            in
                dispatcher model_ cmd dispatch

        OSMsg msg ->
            case Game.fromGateway stateModel.game of
                Just data ->
                    let
                        ( os, cmd, dispatch ) =
                            OS.update data msg stateModel.os

                        stateModel_ =
                            { stateModel | os = os }

                        model_ =
                            { model | state = Play stateModel_ }

                        cmd_ =
                            Cmd.map OSMsg cmd
                    in
                        dispatcher model_ cmd_ dispatch

                Nothing ->
                    ( model, Cmd.none )

        GameMsg msg ->
            let
                ( game, cmd, dispatch ) =
                    updateGame msg stateModel.game

                stateModel_ =
                    { stateModel | game = game }

                model_ =
                    { model | state = Play stateModel_ }
            in
                dispatcher model_ cmd dispatch

        _ ->
            ( model, Cmd.none )


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


updateEvent : Events.Event -> Model -> ( Model, Cmd Msg )
updateEvent event ({ state } as model) =
    let
        msg =
            Game.Event event
    in
        case state of
            Setup stateModel ->
                let
                    ( game, cmd, dispatch ) =
                        updateGame msg stateModel.game

                    stateModel_ =
                        { stateModel | game = game }

                    model_ =
                        { model | state = Setup stateModel_ }
                in
                    dispatcher model_ cmd dispatch

            Play stateModel ->
                let
                    ( game, cmd, dispatch ) =
                        updateGame msg stateModel.game

                    stateModel_ =
                        { stateModel | game = game }

                    model_ =
                        { model | state = Play stateModel_ }
                in
                    dispatcher model_ cmd dispatch

            _ ->
                ( model, Cmd.none )


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

        OSMsg (OS.SessionManagerMsg (SM.WindowManagerMsg (WM.OnDragBy _))) ->
            msg

        OSMsg (OS.SessionManagerMsg (SM.WindowManagerMsg (WM.DragMsg _))) ->
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
    if isDev model then
        let
            logged =
                dispatch
                    |> Dispatch.toList
                    |> List.map sent

            cmd_ =
                Cmd.batch [ cmd, Dispatch.toCmd dispatch ]
        in
            ( model, cmd_ )
    else
        -- TODO: check if reversing is really needed
        Dispatch.foldr reducer ( model, cmd ) dispatch


reducer : Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
reducer msg ( model, cmd ) =
    let
        ( model_, cmd_ ) =
            update msg model
    in
        ( model_, Cmd.batch [ cmd, cmd_ ] )
