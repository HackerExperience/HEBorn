module Apps.BounceManager.Launch exposing (..)

import Random.Pcg as Random
import Utils.React as React exposing (React)
import Utils.Maybe as Maybe
import Utils.Model.RandomUuid as Random
import Game.Account.Bounces.Shared as Bounces
import Game.Account.Bounces.Models as Bounces
import Apps.BounceManager.Config exposing (..)
import Apps.BounceManager.Models exposing (..)
import Apps.BounceManager.Messages exposing (..)
import Apps.BounceManager.Shared exposing (..)


type alias LaunchResponse msg =
    ( Model, React msg )


launch : Config msg -> Maybe Params -> LaunchResponse msg
launch config maybeParams =
    let
        reactRandom =
            Random.intRng
                |> Random.generate (SetInitialSeed >> config.toMsg)
                |> React.cmd

        ( model, react ) =
            case maybeParams of
                Just (WithBounce bounceId) ->
                    launchWithBounce config bounceId

                Nothing ->
                    launchDefault config
    in
        ( model, React.batch config.batchMsg [ reactRandom, react ] )


launchDefault : Config msg -> LaunchResponse msg
launchDefault config =
    ( initialModel config.reference, React.none )


launchWithBounce : Config msg -> Bounces.ID -> LaunchResponse msg
launchWithBounce config bounceId =
    let
        maybeBounce =
            Bounces.get bounceId config.bounces

        selected =
            case Maybe.uncurry (Just bounceId) maybeBounce of
                Just ( bounceId, bounce ) ->
                    TabBuild ( Just bounceId, bounce )

                Nothing ->
                    TabManage

        path =
            case selected of
                TabBuild ( _, bounce ) ->
                    bounce.path

                TabManage ->
                    []

        selectedBounce =
            Maybe.uncurry (Just <| Just bounceId) maybeBounce

        model =
            config.reference
                |> initialModel
                |> setSelectedTab selected
                |> setPath path
                |> setSelectedBounce selectedBounce
    in
        ( model, React.none )
