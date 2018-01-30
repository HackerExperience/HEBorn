module Apps.Hebamp.Launch exposing (..)

import Utils.React as React exposing (React)
import Game.Meta.Types.Apps.Desktop exposing (Reference)
import Apps.Hebamp.Config exposing (..)
import Apps.Hebamp.Models exposing (..)
import Apps.Hebamp.Shared exposing (..)


type alias LaunchResponse msg =
    ( Model, React msg )


launch : Config msg -> Maybe Params -> LaunchResponse msg
launch config maybeParams =
    case maybeParams of
        Just (OpenPlaylist playlist) ->
            launchOpenPlaylist config playlist

        Nothing ->
            ( initialModel config.reference [], React.none )


launchOpenPlaylist : Config msg -> List AudioData -> LaunchResponse msg
launchOpenPlaylist config playlist =
    let
        model =
            initialModel config.reference playlist
    in
        ( model, React.none )
