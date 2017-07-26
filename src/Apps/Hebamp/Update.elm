module Apps.Hebamp.Update exposing (update, loaded)

import Utils.Ports.Audio exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.Hebamp.Models exposing (Model)
import Apps.Hebamp.Messages as Hebamp exposing (Msg(..))
import Apps.Hebamp.Menu.Messages as Menu
import Apps.Hebamp.Menu.Update as Menu
import Apps.Hebamp.Menu.Actions as Menu


update :
    Game.Data
    -> Hebamp.Msg
    -> Model
    -> ( Model, Cmd Hebamp.Msg, Dispatch )
update data msg ({ app } as model) =
    case msg of
        -- -- Context
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            let
                ( menu_, cmd, coreMsg ) =
                    Menu.update data msg model.menu

                cmd_ =
                    Cmd.map MenuMsg cmd
            in
                ( { model | menu = menu_ }, cmd_, coreMsg )

        -- Intenals
        TimeUpdate time ->
            let
                app_ =
                    { app | currentTime = time }

                model_ =
                    { model | app = app_ }
            in
                ( model_, Cmd.none, Dispatch.none )

        Play ->
            let
                cmd_ =
                    app.playerId
                        |> Maybe.map play
                        |> Maybe.withDefault Cmd.none
            in
                ( model, cmd_, Dispatch.none )

        Pause ->
            let
                cmd_ =
                    app.playerId
                        |> Maybe.map pause
                        |> Maybe.withDefault Cmd.none
            in
                ( model, cmd_, Dispatch.none )

        SetCurrentTime time ->
            let
                cmd_ =
                    app.playerId
                        |> Maybe.map ((flip (,)) time >> setCurrentTime)
                        |> Maybe.withDefault Cmd.none
            in
                ( model, cmd_, Dispatch.none )


loaded :
    String
    -> Game.Data
    -> Model
    -> ( Model, Cmd Hebamp.Msg, Dispatch )
loaded wId data ({ app } as model) =
    let
        app_ =
            { app | playerId = Just <| "hebamp-" ++ wId }

        model_ =
            { model | app = app_ }
    in
        ( model_, Cmd.none, Dispatch.none )
