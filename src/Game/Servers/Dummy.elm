module Game.Servers.Dummy exposing (dummy)

import Game.Servers.Models exposing (..)
import Game.Servers.Filesystem.Dummy as Filesystem
import Game.Servers.Logs.Dummy as Logs
import Game.Servers.Processes.Dummy as Processes
import Game.Servers.Tunnels.Dummy as Tunnels


dummy : Model
dummy =
    initialModel
        |> insert "gateway0" (dummyServer "192.168.0.16")
        |> insert "gateway1" (dummyServer "192.168.0.18")
        |> insert "remote0" (dummyServer "153.249.31.179")
        |> insert "remote1" (dummyServer "143.239.31.169")



-- internals


dummyServer : String -> Server
dummyServer ip =
    { type_ = LocalServer
    , ip = ip
    , filesystem = Filesystem.dummy
    , logs = Logs.dummy
    , processes = Processes.dummy
    , tunnels = Tunnels.dummy
    }
