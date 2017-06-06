module Game.Servers.Processes.Dummy exposing (..)

import Dict
import Game.Servers.Processes.Models exposing (Processes, Process, ProcessProp(LocalProcess))
import Game.Servers.Processes.Types.Local as Local exposing (..)


dummyLocalProcess : Local.ProcessProp
dummyLocalProcess =
    Local.ProcessProp
        (Cracker 1.1)
        3
        StateRunning
        (Just 1514764801000)
        (Just 0.5)
        Nothing
        "san"
        "francisco"
        Nothing
        Nothing
        1900000000
        786000000
        0
        0


dummyProcesses : Processes
dummyProcesses =
    Dict.fromList
        -- DUMMY VALUE FOR PLAYING
        [ ( "dummy0000", (Process "dummy0000" (LocalProcess dummyLocalProcess)) )
        ]
