module Game.Account.Bounces.Dummy exposing (dummy)

import Game.Account.Bounces.Models exposing (..)


dummy : Model
dummy =
    let
        bounce0 =
            { name = "Pwned -> Rekt"
            , path =
                [ { ip = "153.249.31.179"
                  , id = "::"
                  }
                , { ip = "143.239.31.169"
                  , id = "::"
                  }
                ]
            }

        bounce1 =
            { name = "Rekt -> Pwned"
            , path =
                [ { ip = "143.239.31.169"
                  , id = "::"
                  }
                , { ip = "153.249.31.179"
                  , id = "::"
                  }
                ]
            }

        model_ =
            initialModel
                |> insert "aaaa" bounce0
                |> insert "bbbb" bounce1
    in
        model_
