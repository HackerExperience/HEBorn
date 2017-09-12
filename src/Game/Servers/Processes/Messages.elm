module Game.Servers.Processes.Messages exposing (Msg(..), RequestMsg(..))

import Events.Events as Events
import Requests.Types exposing (ResponseType)
import Game.Servers.Processes.Models exposing (..)


type Msg
    = Pause ID
    | Resume ID
    | Remove ID
    | Start Type ServerID ServerID (Maybe Version) (Maybe FileID)
    | Complete ID
    | Request RequestMsg
    | Event Events.Event


type RequestMsg
    = BruteforceRequest ResponseType
