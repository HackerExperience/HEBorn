module Game.Account.Database.Dummy exposing (dummy)

import Game.Account.Database.Models exposing (..)


dummy : Model
dummy =
    Model
        [ { nip = ( "::", "153.249.31.179" )
          , password = "WhenYouWereHereBefore"
          , label = Just "Creep 1"
          , notes = Just "Weirdo"
          , virusInstalled =
                [ ( "dummyVirus", "GrandpaChair.mlw", 2.1 )
                , ( "dummyThrojan", "GrandmaTshirt.mlw", 2.0 )
                ]
          , activeVirus = Just ( "dummyThrojan", 1498589047000 )
          , type_ = Player
          , remoteConn = Nothing
          }
        , { nip = ( "::", "143.239.31.169" )
          , password = "WhenYouWereHereBefore"
          , label = Just "Creep 2"
          , notes = Just "Weirdo"
          , virusInstalled =
                [ ( "dummyVirus", "GrandpaChair.mlw", 2.1 )
                , ( "dummyThrojan", "GrandmaTshirt.mlw", 2.0 )
                ]
          , activeVirus = Just ( "dummyThrojan", 1498589047000 )
          , type_ = Player
          , remoteConn = Nothing
          }
        ]
        []
        []
