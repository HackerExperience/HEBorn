module Core.Update exposing (update)

import Core.Messages exposing (..)
import Core.Models exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Driver.Websocket.Messages as Websocket
import Driver.Websocket.Update as Websocket
import Driver.Websocket.Reports exposing (..)
import Events.Events as Events exposing (..)
import Game.Messages as Game
import Game.Update as Game
import Landing.Update as Landing
import OS.Messages as OS
import OS.Update as OS


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (onDebug model received msg) of
        Bootstrap token id ->
            let
                model_ =
                    connect token id model
            in
                ( model_, Cmd.none )

        WebsocketMsg (Websocket.Broadcast (Report (Connected token _))) ->
            -- special trap to catch websocket connections
            let
                model1 =
                    login token model

                ( model_, cmd ) =
                    generic msg model1
            in
                ( model_, cmd )

        WebsocketMsg (Websocket.Broadcast (Report Disconnected)) ->
            -- special trap to catch websocket disconnections
            let
                ( model1, cmd ) =
                    generic msg model

                model_ =
                    logout model
            in
                ( model_, cmd )

        _ ->
            generic msg model



-- internals


generic : Msg -> Model -> ( Model, Cmd Msg )
generic msg model =
    case model of
        Home model ->
            let
                ( model_, cmd ) =
                    home msg model
            in
                ( model_, cmd )

        Play model ->
            let
                ( model_, cmd ) =
                    play msg model
            in
                ( model_, cmd )


home : Msg -> HomeModel -> ( Model, Cmd Msg )
home msg model =
    case msg of
        LandingMsg msg ->
            let
                ( landing, cmd, dispatch ) =
                    Landing.update model msg model.landing

                model_ =
                    Home { model | landing = landing }

                cmd_ =
                    Cmd.map LandingMsg cmd
            in
                dispatcher model_ cmd_ dispatch

        _ ->
            ( Home model, Cmd.none )


play : Msg -> PlayModel -> ( Model, Cmd Msg )
play msg model =
    case msg of
        WebsocketMsg (Websocket.Broadcast event) ->
            -- special trap to route broadcasts to Game
            game (Game.Event event) model

        WebsocketMsg msg ->
            websocket msg model

        GameMsg msg ->
            game msg model

        OSMsg msg ->
            os msg model

        _ ->
            ( Play model, Cmd.none )


websocket : Websocket.Msg -> PlayModel -> ( Model, Cmd Msg )
websocket msg model =
    let
        ( websocket, cmd ) =
            Websocket.update msg model.websocket

        model_ =
            Play { model | websocket = websocket }

        cmd_ =
            Cmd.map WebsocketMsg cmd
    in
        ( model_, cmd_ )


game : Game.Msg -> PlayModel -> ( Model, Cmd Msg )
game msg model =
    let
        ( game, cmd, dispatch ) =
            Game.update msg model.game

        model_ =
            Play { model | game = game }

        cmd_ =
            Cmd.map GameMsg cmd
    in
        dispatcher model_ cmd_ dispatch


os : OS.Msg -> PlayModel -> ( Model, Cmd Msg )
os msg model =
    let
        ( os, cmd, dispatch ) =
            OS.update model.game msg model.os

        model_ =
            Play { model | os = os }

        cmd_ =
            Cmd.map OSMsg cmd
    in
        dispatcher model_ cmd_ dispatch



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


received : a -> a
received =
    Debug.log "▶ Message"


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
