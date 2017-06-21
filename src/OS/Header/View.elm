module OS.Header.View exposing (view)

import Html exposing (..)
import Html.Events exposing (..)
import OS.Header.Models exposing (..)
import Game.Models as Game
import Core.Messages as Core
import Core.Dispatcher exposing (callAccount)
import Game.Account.Messages as Account


view : Game.Model -> Model -> Html Core.Msg
view game model =
    div []
        [ button
            [ onClick (callAccount Account.Logout)
            ]
            [ text "logout" ]
        ]
