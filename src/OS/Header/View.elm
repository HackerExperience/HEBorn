module OS.Header.View exposing (view)

import Html exposing (..)
import Html.Events exposing (..)
import OS.Header.Models exposing (..)
import Game.Models exposing (GameModel)
import Core.Messages exposing (CoreMsg)
import Core.Dispatcher exposing (callAccount)
import Game.Account.Messages exposing (AccountMsg(Logout))


view : GameModel -> Model -> Html CoreMsg
view game model =
    div []
        [ button
            [ onClick (callAccount Logout)
            ]
            [ text "logout" ]
        ]
