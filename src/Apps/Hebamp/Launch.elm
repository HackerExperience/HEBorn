module Apps.Hebamp.Launch exposing (..)

import Utils.React as React exposing (React)
import Apps.Reference exposing (..)
import Apps.Hebamp.Config exposing (..)
import Apps.Hebamp.Models exposing (..)
import Apps.Hebamp.Shared exposing (..)


type alias LaunchResponse msg =
    ( Model, React msg )


launch : Config msg -> Maybe Params -> Reference -> LaunchResponse msg
launch config maybeParams me =
    case maybeParams of
        Just (OpenPlaylist playlist) ->
            launchOpenPlaylist config playlist me

        Nothing ->
            ( initialModel me.windowId [], React.none )


launchOpenPlaylist : Config msg -> List AudioData -> Reference -> LaunchResponse msg
launchOpenPlaylist _ playlist { windowId } =
    let
        model =
            initialModel windowId playlist
    in
        ( model, React.none )
