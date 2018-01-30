module Apps.BounceManager.Launch exposing (..)

import Utils.React as React exposing (React)
import Game.Meta.Types.Apps.Desktop exposing (Reference)
import Apps.BounceManager.Config exposing (..)
import Apps.BounceManager.Models exposing (..)


type alias LaunchResponse msg =
    ( Model, React msg )


launch : Config msg -> Maybe Params -> LaunchResponse msg
launch config maybeParams =
    case maybeParams of
        _ ->
            ( initialModel config.reference, React.none )
