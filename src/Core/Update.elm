module Core.Update exposing (update)

import Utils
import Router.Router exposing (parseLocation)
import Core.Messages exposing (CoreMsg(..))
import Core.Models exposing (CoreModel)
import OS.Update as OS
import Game.Update
import Game.Messages as Game
import Landing.Update
import Driver.Websocket.Update
import Driver.Websocket.Messages as Websocket


update : CoreMsg -> CoreModel -> ( CoreModel, Cmd CoreMsg )
update msg model =
    case (onDebug model received msg) of
        MsgGame msg ->
            updateGame msg model

        MsgWebsocket (Websocket.Broadcast event) ->
            -- special trap to route broadcasts to Game
            updateGame (Game.Event event) model

        MsgOS msg ->
            let
                ( os, cmd, msgs ) =
                    OS.update msg model.game model.os

                model_ =
                    { model | os = os }

                cmd_ =
                    Cmd.map MsgOS cmd
            in
                route model_ cmd_ msgs

        MsgLand msg ->
            let
                ( landing, cmd, msgs ) =
                    Landing.Update.update msg model.landing model

                model_ =
                    { model | landing = landing }

                cmd_ =
                    Cmd.map MsgLand cmd
            in
                route model_ cmd_ msgs

        MsgWebsocket subMsg ->
            let
                ( websocket_, cmd, msgs ) =
                    Driver.Websocket.Update.update subMsg model.websocket model

                model_ =
                    { model | websocket = websocket_ }

                cmd_ =
                    Cmd.map MsgWebsocket cmd
            in
                route model_ cmd_ msgs

        OnLocationChange location ->
            let
                model_ =
                    { model | route = parseLocation location }
            in
                ( model_, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- internals


updateGame : Game.GameMsg -> CoreModel -> ( CoreModel, Cmd CoreMsg )
updateGame msg model =
    let
        ( game, cmd, msgs ) =
            Game.Update.update msg model.game

        model_ =
            { model | game = game }

        cmd_ =
            Cmd.map MsgGame cmd
    in
        route model_ cmd_ msgs


isDev : CoreModel -> Bool
isDev model =
    -- make this function return False to test the game on production mode
    model.game.meta.config.version == "dev"


onDebug : CoreModel -> (a -> a) -> a -> a
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


route : CoreModel -> Cmd CoreMsg -> List CoreMsg -> ( CoreModel, Cmd CoreMsg )
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


reducer : CoreMsg -> ( CoreModel, Cmd CoreMsg ) -> ( CoreModel, Cmd CoreMsg )
reducer msg ( model, cmd ) =
    let
        ( model_, cmd_ ) =
            update msg model
    in
        ( model_, Cmd.batch [ cmd, cmd_ ] )
