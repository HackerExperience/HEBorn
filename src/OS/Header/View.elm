module OS.Header.View exposing (view)

import Html exposing (..)
import Html.Events exposing (..)
import OS.Header.Messages exposing (..)
import OS.Header.Models exposing (..)
import Game.Models as Game


view : Game.Model -> Model -> Html Msg
view game model =
    div []
        [ button
            [ onClick Logout
            ]
            [ text "logout" ]
        ]
