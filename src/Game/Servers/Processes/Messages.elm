module Game.Servers.Processes.Messages exposing (Msg(..))

import Game.Servers.Processes.Types.Shared exposing (ProcessID)


type Msg
    = Pause ProcessID
    | Resume ProcessID
    | Complete ProcessID
    | Remove ProcessID
