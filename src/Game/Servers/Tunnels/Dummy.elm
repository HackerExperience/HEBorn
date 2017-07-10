module Game.Servers.Tunnels.Dummy exposing (dummy)

import Dict exposing (Dict)
import Game.Servers.Tunnels.Models exposing (..)


dummy : Model
dummy =
    { tunnels = Dict.empty
    , active = Nothing
    }
