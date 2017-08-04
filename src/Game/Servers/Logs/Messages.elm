module Game.Servers.Logs.Messages exposing (Msg(..))

import Json.Decode exposing (Value)
import Game.Servers.Logs.Models exposing (ID, StdData)


type Msg
    = BootstrapLogs Value
    | UpdateContent ID String
    | Crypt ID
    | Uncrypt ID String
    | Hide ID
    | Unhide StdData
    | Delete ID
