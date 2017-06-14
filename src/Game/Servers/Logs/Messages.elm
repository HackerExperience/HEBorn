module Game.Servers.Logs.Messages exposing (Msg(..))

import Game.Servers.Logs.Models exposing (ID, StdData)


type Msg
    = UpdateContent ID String
    | Crypt ID
    | Uncrypt ID String
