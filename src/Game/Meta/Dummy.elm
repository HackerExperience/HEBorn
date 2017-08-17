module Game.Meta.Dummy exposing (dummy)

import Game.Meta.Models exposing (..)


dummy : Model
dummy =
    let
        model =
            initialModel

        model_ =
            { model | gateway = Just "gate1" }
    in
        model_
