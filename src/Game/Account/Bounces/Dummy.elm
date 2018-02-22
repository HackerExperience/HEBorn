module Game.Account.Bounces.Dummy exposing (dummy)

import Game.Account.Bounces.Models exposing (..)


dummy : Model
dummy =
    let
        bounce0 =
            { name = "Pwned -> Rekt"
            , path =
                [ ( "::1", "123.426.988.546" )
                , ( "::1", "133.234.253.333" )
                ]
            }

        bounce1 =
            { name = "Rekt -> Pwned"
            , path =
                [ ( "::1", "133.234.253.333" )
                , ( "::1", "123.426.988.546" )
                ]
            }

        model_ =
            initialModel
                |> insert "aaaa" bounce0
                |> insert "bbbb" bounce1
    in
        model_
