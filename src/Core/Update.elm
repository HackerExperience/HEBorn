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
import OS.Messages as OS
import OS.Update as OS
import OS.SessionManager.WindowManager.Messages as WM
import OS.SessionManager.Messages as SM


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (onDebug model received msg) of
        Boot id username token ->
            let
                model_ =
                    connect id username token model
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
                model1 =
                    login model

                ( model_, cmd ) =
                    generic msg model1
            in
                ( model_, cmd )

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

        Play playState ->
            let
                ( model_, cmd ) =
                    play model msg playState
            in
                ( model_, cmd )


home : Model -> Msg -> HomeModel -> ( Model, Cmd Msg )
home model msg state =
    case msg of
        LandingMsg msg ->
            let
                ( landing, cmd, dispatch ) =
                    Landing.update model msg state.landing

                state_ =
                    Home { state | landing = landing }

                model_ =
                    { model | state = state_ }

                cmd_ =
                    Cmd.map LandingMsg cmd
            in
                dispatcher model_ cmd_ dispatch

        _ ->
            ( model, Cmd.none )


setup : Model -> Msg -> SetupModel -> ( Model, Cmd Msg )
setup model msg state =
    case msg of
        _ ->
            ( model, Cmd.none )


play : Model -> Msg -> PlayModel -> ( Model, Cmd Msg )
play model msg state =
    case msg of
        WebsocketMsg (Ws.Broadcast event) ->
            -- special trap to route broadcasts to Game
            game model (Game.Event event) state

        WebsocketMsg msg ->
            websocket model msg state

        GameMsg msg ->
            game model msg state

        OSMsg msg ->
            os model msg state

        _ ->
            ( model, Cmd.none )


websocket : Model -> Ws.Msg -> PlayModel -> ( Model, Cmd Msg )
websocket model msg state =
    let
        ( websocket, cmd ) =
            Ws.update msg state.websocket

        state_ =
            Play { state | websocket = websocket }

        model_ =
            { model | state = state_ }

        cmd_ =
            Cmd.map WebsocketMsg cmd
    in
        ( model_, cmd_ )


game : Model -> Game.Msg -> PlayModel -> ( Model, Cmd Msg )
game model msg state =
    let
        ( game, cmd, dispatch ) =
            Game.update msg state.game

        state_ =
            Play { state | game = game }

        model_ =
            { model | state = state_ }

        cmd_ =
            Cmd.map GameMsg cmd
    in
        dispatcher model_ cmd_ dispatch


os : Model -> OS.Msg -> PlayModel -> ( Model, Cmd Msg )
os model msg state =
    case Game.fromGateway state.game of
        Just data ->
            let
                ( os, cmd, dispatch ) =
                    OS.update data msg state.os

                state_ =
                    Play { state | os = os }

                model_ =
                    { model | state = state_ }

                cmd_ =
                    Cmd.map OSMsg cmd
            in
                dispatcher model_ cmd_ dispatch

        Nothing ->
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
