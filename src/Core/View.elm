module Core.View exposing (view)

import Html exposing (..)
import Core.Messages exposing (..)
import Core.Models exposing (..)
import OS.View as OS
import Landing.View as Landing


view : Model -> Html Msg
view model =
    case model of
        Home model ->
            Html.map LandingMsg (Landing.view model)

        Play model ->
            Html.map OSMsg (OS.view model)
