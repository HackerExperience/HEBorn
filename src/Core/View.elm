module Core.View exposing (view)

import Html exposing (..)
import Core.Error as Error
import Core.Config exposing (..)
import Core.Messages exposing (..)
import Core.Models exposing (..)
import Game.Data as GameD
import Game.Models as Game
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

        game =
            play.game

        activeServer =
            case Game.getActiveServer play.game of
                Just ( _, activeServer ) ->
                    activeServer

                Nothing ->
                    "Player has no active Server"
                        |> Error.astralProj
                        |> uncurry Native.Panic.crash

        lastTick =
            game
                |> Game.getMeta
                |> Meta.getLastTick

        account =
            Game.getAccount game

        story =
            Game.getStory game

        config =
            osConfig account story lastTick activeServer
    in
        case GameD.fromGateway game of
            Just inBieber ->
                OS.view config inBieber play.os

            Nothing ->
                Panic.view "WTF_ASTRAL_PROJECTION"
                    "Player has no active gateway!"
