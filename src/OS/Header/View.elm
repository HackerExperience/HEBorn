module OS.Header.View exposing (view)

import Html exposing (..)
import Html.Events exposing (..)
import Core.Models exposing (CoreModel)
import Core.Messages exposing (CoreMsg)
import Core.Dispatcher exposing (callAccount)
import Game.Account.Messages exposing (AccountMsg(Logout))


view : CoreModel -> Html CoreMsg
view model =
    div []
        [ button
            [ onClick (callAccount Logout)
            ]
            [ text "logout" ]
        ]
