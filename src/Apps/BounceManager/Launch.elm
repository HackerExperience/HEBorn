module Apps.BounceManager.Launch exposing (..)

import Utils.React as React exposing (React)
import Apps.Reference exposing (..)
import Apps.BounceManager.Config exposing (..)
import Apps.BounceManager.Models exposing (..)


type alias LaunchResponse msg =
    ( Model, React msg )


launch : Config msg -> Maybe Params -> Reference -> LaunchResponse msg
launch config maybeParams me =
    case maybeParams of
        _ ->
            ( initialModel me, React.none )
