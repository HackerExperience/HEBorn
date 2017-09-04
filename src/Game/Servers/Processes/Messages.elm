module Game.Servers.Processes.Messages exposing (Msg(..), RequestMsg(..))

import Events.Events as Events
import Requests.Types exposing (ResponseType)
import Game.Servers.Processes.Types.Shared exposing (ProcessID)
import Game.Servers.Processes.Models exposing (ProcessProp)


type Msg
    = Pause ProcessID
    | Resume ProcessID
    | Complete ProcessID
    | Remove ProcessID
    | Create ( ProcessID, ProcessProp )
    | Request RequestMsg
    | Event Events.Event

type RequestMsg
    = BruteforceRequest ResponseType
