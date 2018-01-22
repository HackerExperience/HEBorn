module Core.View exposing (view)

import Html exposing (..)
import Core.Error as Error
import Core.Config exposing (..)
import Core.Messages exposing (..)
import Core.Models exposing (..)
import Game.Models as Game
import Game.Account.Models as Account
import Game.Meta.Models as Meta
import OS.View as OS
import Landing.View as Landing
import Setup.View as Setup
import Core.Panic as Panic


view : Model -> Html Msg
view model =
    case model.state of
        Home home ->
            Landing.view (landingConfig model.windowLoaded model.flags)
                home.landing

        Setup setup ->
            onSetup setup model

        Play play ->
            onPlay play

        Panic code message ->
            Panic.view code message


onSetup : SetupModel -> Model -> Html Msg
onSetup { game, setup } model =
    case game.account.mainframe of
        Just inBieber ->
            let
                config =
                    setupConfig
                        game.account.id
                        inBieber
                        game.flags
            in
                Setup.view config setup

        Nothing ->
            "Player doesn't have a Mainframe [View.setup]"
                |> Error.astralProj
                |> uncurry Panic.view


onPlay : PlayModel -> Html Msg
onPlay { game, os } =
    -- CONFREFACT: Get rid of `data`
    let
        volatile_ =
            ( Game.getGateway game
            , Game.getActiveServer game
            )

        ctx =
            Account.getContext <| Game.getAccount game
    in
        case volatile_ of
            ( Just gtw, Just srv ) ->
                OS.view (osConfig game srv ctx gtw) os

            ( Nothing, _ ) ->
                "Player doesn't have a Gateway [View.play]"
                    |> Error.astralProj
                    |> uncurry Panic.view

            ( _, Nothing ) ->
                "Player doesn't have an active server [View.play]"
                    |> Error.astralProj
                    |> uncurry Panic.view
