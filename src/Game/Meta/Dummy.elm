module Game.Meta.Dummy exposing (dummy)

import Game.Meta.Models exposing (..)


dummy : Model
dummy =
    let
        model =
            initialModel

        model_ =
            { model | gateway = Just "gateway0" }
    in
        model_
