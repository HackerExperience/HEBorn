module Core.Update exposing (update)

import Core.Messages exposing (..)
import Core.Models exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Driver.Websocket.Messages as Ws
import Driver.Websocket.Update as Ws
import Driver.Websocket.Reports exposing (..)
import Events.Events as Events exposing (..)
import Landing.Update as Landing
import Game.Data as Game
import Game.Messages as Game
import Game.Meta.Messages as Meta
import Game.Update as Game
import Setup.Messages as Setup
import Setup.Update as Setup
import OS.Messages as OS
import OS.Update as OS
import OS.SessionManager.WindowManager.Messages as WM
import OS.SessionManager.Messages as SM


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (onDebug model received msg) of
        Boot id username token firstRun ->
            let
                model_ =
                    connect id username token firstRun model
            in
                ( model_, Cmd.none )

        Shutdown ->
            let
                ( model1, cmd ) =
                    generic msg model

                model_ =
                    logout model
            in
                ( model_, cmd )

        WebsocketMsg (Ws.Broadcast (Report (Connected _))) ->
            -- special trap to catch websocket connections
            let
                ( model1, cmd1, dispatch ) =
                    login model

                ( model_, cmd2 ) =
                    generic msg model1

                cmd_ =
                    Cmd.batch [ cmd1, cmd2 ]
            in
                dispatcher model_ cmd_ dispatch

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
            generic msg model



-- internals


generic : Msg -> Model -> ( Model, Cmd Msg )
generic msg ({ state } as model) =
    case state of
        Home homeState ->
            let
                ( model_, cmd ) =
                    home model msg homeState
            in
                ( model_, cmd )

        Setup setupState ->
            let
                ( model_, cmd ) =
                    setup model msg setupState
            in
                ( model_, cmd )

        Play _ ->
            let
                ( model_, cmd ) =
                    play msg model
            in
                ( model_, cmd )


home : Model -> Msg -> HomeModel -> ( Model, Cmd Msg )
home model msg ({ landing } as state) =
    case msg of
        LandingMsg msg ->
            let
                ( landing_, cmd, dispatch ) =
                    Landing.update model msg landing

                home_ =
                    { state | landing = landing_ }

                model_ =
                    { model | state = Home home_ }

                cmd_ =
                    Cmd.map LandingMsg cmd
            in
                dispatcher model_ cmd_ dispatch

        _ ->
            ( model, Cmd.none )


setup : Model -> Msg -> SetupModel -> ( Model, Cmd Msg )
setup model msg ({ game, setup } as setupState) =
    case msg of
        WebsocketMsg (Ws.Broadcast event) ->
            -- special trap to route broadcasts to Game
            let
                ( setup_, cmd, dispatch ) =
                    Setup.update game (Setup.Event event) setup

                cmd_ =
                    Cmd.map SetupMsg cmd

                setupState_ =
                    { setupState | setup = setup }

                model_ =
                    { model | state = Setup setupState_ }
            in
                dispatcher model_ cmd_ dispatch

        WebsocketMsg msg ->
            websocket msg model

        SetupMsg msg ->
            let
                ( setup_, cmd, dispatch ) =
                    Setup.update game msg setup

                cmd_ =
                    Cmd.map SetupMsg cmd

                setupState_ =
                    { setupState | setup = setup_ }

                model_ =
                    { model | state = Setup setupState_ }
            in
                dispatcher model_ cmd_ dispatch

        _ ->
            ( model, Cmd.none )


play : Msg -> Model -> ( Model, Cmd Msg )
play msg model =
    case msg of
        WebsocketMsg (Ws.Broadcast event) ->
            -- special trap to route broadcasts to Game
            game (Game.Event event) model

        WebsocketMsg msg ->
            websocket msg model

        GameMsg msg ->
            game msg model

        OSMsg msg ->
            os msg model

        _ ->
            ( model, Cmd.none )


websocket : Ws.Msg -> Model -> ( Model, Cmd Msg )
websocket msg ({ state } as model) =
    case state of
        Home ({ websocket } as home) ->
            case websocket of
                Just websocket ->
                    let
                        ( websocket_, cmd, dispatch ) =
                            Ws.update msg websocket

                        home_ =
                            { home | websocket = Just websocket_ }

                        cmd_ =
                            Cmd.map WebsocketMsg cmd

                        model_ =
                            { model | state = Home home_ }
                    in
                        dispatcher model_ cmd_ dispatch

                Nothing ->
                    ( model, Cmd.none )

        Play ({ websocket } as play) ->
            let
                ( websocket_, cmd, dispatch ) =
                    Ws.update msg websocket

                play_ =
                    { play | websocket = websocket_ }

                cmd_ =
                    Cmd.map WebsocketMsg cmd

                model_ =
                    { model | state = Play play_ }
            in
                dispatcher model_ cmd_ dispatch

        Setup ({ websocket } as setup) ->
            let
                ( websocket_, cmd, dispatch ) =
                    Ws.update msg websocket

                setup_ =
                    { setup | websocket = websocket_ }

                cmd_ =
                    Cmd.map WebsocketMsg cmd

                model_ =
                    { model | state = Setup setup_ }
            in
                dispatcher model_ cmd_ dispatch


game : Game.Msg -> Model -> ( Model, Cmd Msg )
game msg ({ state } as model) =
    case state of
        Home home ->
            ( model, Cmd.none )

        Play ({ game } as play) ->
            let
                ( game_, cmd, dispatch ) =
                    Game.update msg game

                play_ =
                    { play | game = game_ }

                cmd_ =
                    Cmd.map GameMsg cmd

                model_ =
                    { model | state = Play play_ }
            in
                dispatcher model_ cmd_ dispatch

        Setup ({ game } as setup) ->
            let
                ( game_, cmd, dispatch ) =
                    Game.update msg game

                setup_ =
                    { setup | game = game_ }

                cmd_ =
                    Cmd.map GameMsg cmd

                model_ =
                    { model | state = Setup setup_ }
            in
                dispatcher model_ cmd_ dispatch


os : OS.Msg -> Model -> ( Model, Cmd Msg )
os msg ({ state } as model) =
    case state of
        Play ({ os } as play) ->
            case Game.fromGateway play.game of
                Just data ->
                    let
                        ( os_, cmd, dispatch ) =
                            OS.update data msg os

                        play_ =
                            { play | os = os_ }

                        model_ =
                            { model | state = Play play_ }

                        cmd_ =
                            Cmd.map OSMsg cmd
                    in
                        dispatcher model_ cmd_ dispatch

                Nothing ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )



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
    Debug.log "◀ Message"


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
