module Game.Account.Bounces.Dummy exposing (dummy)

import Game.Account.Bounces.Models exposing (..)


dummy : Model
dummy =
    let
        bounce0 =
            { name = "Pwned -> Rekt"
            , path =
                [ ( "::", "153.249.31.179" )
                , ( "::", "143.239.31.169" )
                ]
            }

        bounce1 =
            { name = "Rekt -> Pwned"
            , path =
                [ ( "::", "143.239.31.169" )
                , ( "::", "153.249.31.179" )
                ]
            }

        model_ =
            initialModel
                |> insert "aaaa" bounce0
                |> insert "bbbb" bounce1
    in
        model_
