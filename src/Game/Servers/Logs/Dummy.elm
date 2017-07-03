module Game.Servers.Logs.Dummy exposing (dummy)

import Dict
import Game.Servers.Logs.Models as Logs exposing (..)


dummy : Logs
dummy =
    Dict.fromList
        -- DUMMY VALUE FOR PLAYING
        (List.map (\( id, raw ) -> ( id, StdLog (StdData id StatusNormal 0 raw (interpretRawContent raw) NoEvent) ))
            [ ( "dummy0000", "174.57.204.104 logged in as root" )
            , ( "dummy0001", "localhost bounced connection from 174.57.204.104 to 209.43.107.189" )
            ]
        )
