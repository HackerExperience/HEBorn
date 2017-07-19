module Game.Servers.Dummy exposing (dummy)

import Game.Servers.Models exposing (..)
import Game.Network.Types exposing (NIP)
import Game.Servers.Filesystem.Dummy as Filesystem
import Game.Servers.Logs.Dummy as Logs
import Game.Servers.Processes.Dummy as Processes
import Game.Servers.Tunnels.Dummy as Tunnels


dummy : Model
dummy =
    let
        meta0 =
            GatewayMeta <| GatewayMetadata Nothing Nothing

        meta1 =
            EndpointMeta {}
    in
        initialModel
            |> insert "gateway0"
                (dummyServer "Main"
                    ( "::", "192.168.0.16" )
                    meta0
                )
            |> insert "gateway1"
                (dummyServer "Secondary"
                    ( "::", "192.168.0.18" )
                    meta0
                )
            |> insert "remote0"
                (dummyServer "Pwned"
                    ( "::", "153.249.31.179" )
                    meta1
                )
            |> insert "remote1"
                (dummyServer "Rekt"
                    ( "::", "143.239.31.169" )
                    meta1
                )



-- internals


dummyServer : String -> NIP -> ServerMeta -> Server
dummyServer name nip meta =
    { name = name
    , nip = nip
    , nips = [ nip ]
    , filesystem = Filesystem.dummy
    , logs = Logs.dummy
    , processes = Processes.dummy
    , tunnels = Tunnels.dummy
    , meta = meta
    , coordinates = 0
    }
