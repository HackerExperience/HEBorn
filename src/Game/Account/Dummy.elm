module Game.Account.Dummy exposing (dummy)

import Game.Account.Database.Dummy as Database
import Game.Account.Bounces.Dummy as Bounces
import Game.Account.Models exposing (..)


dummy : String -> Model
dummy token =
    let
        model =
            initialModel token

        database =
            Database.dummy

        servers =
            [ "gateway0"
            , "gateway1"
            ]

        bounces =
            Bounces.dummy

        model_ =
            { model
                | database = database
                , servers = servers
                , bounces = bounces
            }
    in
        model_
