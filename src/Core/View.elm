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
view ({ state } as model) =
    case state of
        Home home ->
            Html.map LandingMsg (Landing.view model home.landing)

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
            case Game.fromGateway play.game of
                Just inBieber ->
                    Html.map OSMsg (OS.view inBieber play.os)

                Nothing ->
                    Panic.view "WTF_ASTRAL_PROJECTION"
                        "Player has no active gateway!"

        Panic code message ->
            Panic.view code message
