module OS.Header.View exposing (view)

import Html exposing (..)
import Html.Events exposing (..)
import OS.Header.Messages exposing (..)
import OS.Header.Models exposing (..)
import Game.Data as GameData


view : GameData.Data -> Model -> Html Msg
view game model =
    div []
        [ button
            [ onClick Logout
            ]
            [ text "logout" ]
        ]
