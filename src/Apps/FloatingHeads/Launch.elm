module Apps.FloatingHeads.Launch exposing (..)

import Utils.React as React exposing (React)
import Apps.FloatingHeads.Config exposing (..)
import Apps.FloatingHeads.Models exposing (..)


type alias LaunchResponse msg =
    ( Model, React msg )


launch : Config msg -> Maybe Params -> LaunchResponse msg
launch config maybeParams =
    case maybeParams of
        Just (OpenAtContact contact) ->
            launchOpenAtContact config contact

        Nothing ->
            ( initialModel Nothing config.reference, React.none )


launchOpenAtContact : Config msg -> String -> LaunchResponse msg
launchOpenAtContact config contact =
    let
        model =
            initialModel (Just contact) config.reference
    in
        ( model, React.none )
