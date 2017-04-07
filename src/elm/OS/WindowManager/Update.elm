module OS.WindowManager.Update exposing (..)


import Random.Pcg exposing (Seed)

import OS.Messages exposing (OSMsg)
import Game.Messages exposing (GameMsg)

import OS.WindowManager.Models exposing ( Model
                                        , openWindow, closeWindow)
import OS.WindowManager.Messages exposing (Msg(..))


update : Msg -> Model -> (Model, Cmd OSMsg, List GameMsg, List OSMsg)
update msg model =
    case msg of

        OpenWindow window ->
            let
                (windows_, seed_) = openWindow model window
                model_ = {model | windows = windows_, seed = seed_}
            in
                (model_, Cmd.none, [], [])

        CloseWindow id ->
            let
                windows_ = closeWindow model id
            in
                ({model | windows = windows_}, Cmd.none, [], [])
