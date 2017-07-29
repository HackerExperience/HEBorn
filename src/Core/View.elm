module Core.View exposing (view)

import Html exposing (..)
import Core.Messages exposing (..)
import Core.Models exposing (..)
import Game.Data as Game
import OS.View as OS
import Landing.View as Landing
import Setup.View as Setup


view : Model -> Html Msg
view ({ state } as model) =
    case state of
        Home home ->
            Html.map LandingMsg (Landing.view model home.landing)

        Setup setup ->
            Html.map SetupMsg (Setup.view setup.game setup.setup)

        Play play ->
            case Game.fromGateway play.game of
                Just data ->
                    Html.map OSMsg (OS.view data play.os)

                Nothing ->
                    div [] []
