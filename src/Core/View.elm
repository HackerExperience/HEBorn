module Core.View exposing (view)

import Html exposing (..)
import Core.Config exposing (..)
import Core.Messages exposing (..)
import Core.Models exposing (..)
import Game.Data as Game
import OS.View as OS
import Landing.View as Landing
import Setup.View as Setup
import Core.Panic as Panic


view : Model -> Html Msg
view model =
    case model.state of
        Home home ->
            Landing.view model home.landing
                |> map LandingMsg

        Setup { game, setup } ->
            let
                config =
                    setupConfig
                        game.account.id
                        game.account.mainframe
                        game.flags
            in
                Setup.view config setup

        Play play ->
            onPlay play model

        Panic code message ->
            Panic.view code message


onPlay : PlayModel -> Model -> Html Msg
onPlay play model =
    let
        state =
            model.state

        story =
            play.game.story

        config =
            osConfig story
    in
        case Game.fromGateway play.game of
            Just inBieber ->
                OS.view config inBieber play.os

            Nothing ->
                Panic.view "WTF_ASTRAL_PROJECTION"
                    "Player has no active gateway!"
