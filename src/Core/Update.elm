module Core.Update exposing (update)

import Utils
import Router.Router exposing (parseLocation)
import Core.Messages exposing (..)
import Core.Models exposing (..)
import OS.Update as OS
import Game.Update as Game
import Game.Messages as Game
import Landing.Update
import Driver.Websocket.Update
import Driver.Websocket.Messages as Websocket


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (onDebug model received msg) of
        GameMsg msg ->
            updateGame msg model

        WebsocketMsg (Websocket.Broadcast event) ->
            -- special trap to route broadcasts to Game
            updateGame (Game.Event event) model

        OSMsg msg ->
            let
                ( os, cmd, msgs ) =
                    OS.update msg model.game model.os

                model_ =
                    { model | os = os }

                cmd_ =
                    Cmd.map OSMsg cmd
            in
                route model_ cmd_ msgs

        LandingMsg msg ->
            let
                ( landing, cmd, msgs ) =
                    Landing.Update.update msg model.landing model

                model_ =
                    { model | landing = landing }

                cmd_ =
                    Cmd.map LandingMsg cmd
            in
                route model_ cmd_ msgs

        WebsocketMsg subMsg ->
            let
                ( websocket_, cmd, msgs ) =
                    Driver.Websocket.Update.update subMsg model.websocket model

                model_ =
                    { model | websocket = websocket_ }

                cmd_ =
                    Cmd.map WebsocketMsg cmd
            in
                route model_ cmd_ msgs

        LocationChangeMsg location ->
            let
                model_ =
                    { model | route = parseLocation location }
            in
                ( model_, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- internals


updateGame : Game.Msg -> Model -> ( Model, Cmd Msg )
updateGame msg model =
    let
        ( game, cmd, msgs ) =
            Game.update msg model.game

        model_ =
            { model | game = game }

        cmd_ =
            Cmd.map GameMsg cmd
    in
        route model_ cmd_ msgs


isDev : Model -> Bool
isDev model =
    -- make this function return False to test the game on production mode
    model.game.meta.config.version == "dev"


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


route : Model -> Cmd Msg -> List Msg -> ( Model, Cmd Msg )
route model cmd msgs =
    if isDev model then
        let
            cmds =
                msgs
                    -- TODO: eval if reverse is really needed
                    |> List.reverse
                    |> List.map (sent >> Utils.msgToCmd)

            cmd_ =
                Cmd.batch (cmd :: cmds)
        in
            ( model, cmd_ )
    else
        -- TODO: eval if foldr is really needed
        List.foldr reducer ( model, cmd ) msgs


reducer : Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
reducer msg ( model, cmd ) =
    let
        ( model_, cmd_ ) =
            update msg model
    in
        ( model_, Cmd.batch [ cmd, cmd_ ] )
