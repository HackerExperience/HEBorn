module Game.Servers.Dummy exposing (dummy)

import Game.Servers.Models exposing (..)
import Game.Servers.Filesystem.Dummy as Filesystem
import Game.Servers.Logs.Dummy as Logs
import Game.Servers.Processes.Dummy as Processes
import Game.Servers.Tunnels.Dummy as Tunnels


dummy : Model
dummy =
    initialModel
        |> insert "gateway0" (dummyServer "Main" "192.168.0.16" LocalServer)
        |> insert "gateway1" (dummyServer "Secondary" "192.168.0.18" LocalServer)
        |> insert "remote0" (dummyServer "Pwned" "153.249.31.179" RemoteServer)
        |> insert "remote1" (dummyServer "Rekt" "143.239.31.169" RemoteServer)



-- internals


dummyServer : String -> String -> Type -> Server
dummyServer name ip type_ =
    { name = name
    , type_ = type_
    , ip = ip
    , filesystem = Filesystem.dummy
    , logs = Logs.dummy
    , processes = Processes.dummy
    , tunnels = Tunnels.dummy
    , bounce = Nothing
    , endpoint = Nothing
    }
