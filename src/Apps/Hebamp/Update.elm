module Apps.Hebamp.Update exposing (update)

import Time exposing (Time)
import Utils.React as React exposing (React)
import Utils.Ports.Audio exposing (..)
import Apps.Hebamp.Config exposing (..)
import Apps.Hebamp.Models exposing (..)
import Apps.Hebamp.Messages as Hebamp exposing (Msg(..))
import Apps.Hebamp.Shared exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> Hebamp.Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
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

        Close ->
            onClose config model

        LaunchApp params ->
            onLaunchApp config params model


onTimeUpdate : String -> Float -> Model -> UpdateResponse msg
onTimeUpdate playerId time model =
    let
        model_ =
            if playerId == model.playerId then
                { model | currentTime = time }
            else
                model
    in
        ( model_, React.none )


onPlay : Model -> UpdateResponse msg
onPlay model =
    let
        react =
            React.cmd (play model.playerId)
    in
        ( model, react )


onPause : Model -> UpdateResponse msg
onPause model =
    let
        react =
            React.cmd (pause model.playerId)
    in
        ( model, react )


onClose : Config msg -> Model -> UpdateResponse msg
onClose { onCloseApp } model =
    onCloseApp
        |> React.msg
        |> (,) model


onSetCurrentTime : Time -> Model -> UpdateResponse msg
onSetCurrentTime time model =
    let
        react =
            React.cmd <| setCurrentTime ( model.playerId, time )
    in
        ( model, react )


onLaunchApp : Config msg -> Params -> Model -> UpdateResponse msg
onLaunchApp config params model =
    case params of
        OpenPlaylist playlist ->
            let
                model_ =
                    setPlaylist playlist model
            in
                ( model_, React.none )
