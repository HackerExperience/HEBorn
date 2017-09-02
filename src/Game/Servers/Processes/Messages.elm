module Game.Servers.Processes.Messages exposing (Msg(..))

import Events.Events as Events
import Game.Servers.Processes.Types.Shared exposing (ProcessID)
import Game.Servers.Processes.Models exposing (ProcessProp)


type Msg
    = Pause ProcessID
    | Resume ProcessID
    | Complete ProcessID
    | Remove ProcessID
    | Create ( ProcessID, ProcessProp )
    | Event Events.Event
