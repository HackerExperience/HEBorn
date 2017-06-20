module Game.Servers.Processes.Messages exposing (Msg(..))

import Game.Servers.Processes.Types.Shared exposing (ProcessID)
import Game.Servers.Processes.Models exposing (Process)


type Msg
    = Pause ProcessID
    | Resume ProcessID
    | Complete ProcessID
    | Remove ProcessID
    | Create Process
