module Apps.Hebamp.Update exposing (update)

import Audio exposing (..)
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
                audioData =
                    app.audioData

                audioData_ =
                    { audioData | currentTime = time }

                app_ =
                    { app | audioData = audioData_ }

                model_ =
                    { model | app = app_ }
            in
                ( model_, Cmd.none, Dispatch.none )

        Play ->
            ( model, play "audio-player", Dispatch.none )

        Pause ->
            ( model, pause "audio-player", Dispatch.none )

        SetCurrentTime time ->
            ( model, setCurrentTime ( "audio-player", time ), Dispatch.none )
