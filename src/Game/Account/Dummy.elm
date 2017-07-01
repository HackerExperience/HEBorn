module Game.Account.Dummy exposing (dummy)

import Game.Account.Models exposing (..)
import Game.Account.Database.Dummy as Database exposing (..)


dummy : String -> Model
dummy token =
    let
        model =
            initialModel token

        database =
            Database.dummy
    in
        { model | database = database }
