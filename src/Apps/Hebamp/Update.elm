module Apps.Hebamp.Update exposing (update)

import Utils.Ports.Audio exposing (..)
import Utils.React as React exposing (React)
import Time exposing (Time)
import Apps.Hebamp.Config exposing (..)
import Apps.Hebamp.Models exposing (Model)
import Apps.Hebamp.Messages as Hebamp exposing (Msg(..))


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


onSetCurrentTime : Time -> Model -> UpdateResponse msg
onSetCurrentTime time model =
    let
        react =
            React.cmd <| setCurrentTime ( model.playerId, time )
    in
        ( model, react )
