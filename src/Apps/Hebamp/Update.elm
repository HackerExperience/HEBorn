module Apps.Hebamp.Update exposing (update)

import Utils.Ports.Audio exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Time exposing (Time)
import Apps.Hebamp.Models exposing (Model)
import Apps.Hebamp.Messages as Hebamp exposing (Msg(..))
import Apps.Hebamp.Menu.Messages as Menu
import Apps.Hebamp.Menu.Update as Menu
import Apps.Hebamp.Menu.Actions as Menu


type alias UpdateResponse =
    ( Model, Cmd Hebamp.Msg, Dispatch )


update :
    Game.Data
    -> Hebamp.Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        -- -- Context
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            onMenuMsg data msg model

        -- Intenals
        TimeUpdate playerId time ->
            onTimeUpdate playerId time model

        Play ->
            onPlay model

        Pause ->
            onPause model

        SetCurrentTime time ->
            onSetCurrentTime time model


onMenuMsg : Game.Data -> Menu.Msg -> Model -> UpdateResponse
onMenuMsg data msg model =
    let
        ( menu_, cmd, coreMsg ) =
            Menu.update data msg model.menu

        cmd_ =
            Cmd.map MenuMsg cmd

        model_ =
            { model | menu = menu_ }
    in
        ( model_, cmd_, coreMsg )


onTimeUpdate : String -> Float -> Model -> UpdateResponse
onTimeUpdate playerId time model =
    let
        model_ =
            if playerId == model.playerId then
                { model | currentTime = time }
            else
                model
    in
        ( model_, Cmd.none, Dispatch.none )


onPlay : Model -> UpdateResponse
onPlay model =
    let
        cmd =
            play model.playerId
    in
        ( model, cmd, Dispatch.none )


onPause : Model -> UpdateResponse
onPause model =
    let
        cmd =
            pause model.playerId
    in
        ( model, cmd, Dispatch.none )


onSetCurrentTime : Time -> Model -> UpdateResponse
onSetCurrentTime time model =
    let
        cmd =
            setCurrentTime ( model.playerId, time )
    in
        ( model, cmd, Dispatch.none )
