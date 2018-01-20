module Apps.Hebamp.Update exposing (update)

import Utils.Ports.Audio exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Time exposing (Time)
import Apps.Hebamp.Models exposing (Model)
import Apps.Hebamp.Messages as Hebamp exposing (Msg(..))


type alias UpdateResponse =
    ( Model, Cmd Hebamp.Msg, Dispatch )


update :
    Game.Data
    -> Hebamp.Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        -- Intenals
        TimeUpdate playerId time ->
            onTimeUpdate playerId time model

        Play ->
            onPlay model

        Pause ->
            onPause model

        SetCurrentTime time ->
            onSetCurrentTime time model


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
