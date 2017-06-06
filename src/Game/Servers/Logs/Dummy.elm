module Game.Servers.Logs.Dummy exposing (..)

import Dict
import Game.Servers.Logs.Models exposing (Logs, Log(..), LogData)


dummyLogs : Logs
dummyLogs =
    Dict.fromList
        -- DUMMY VALUE FOR PLAYING
        (List.map (\( x, y ) -> ( x, LogEntry (LogData x y 0) ))
            [ ( "dummy0000", "174.57.204.104 logged in as root" )
            , ( "dummy0001", "localhost bounced connection from 174.57.204.104 to 209.43.107.189" )
            ]
        )
