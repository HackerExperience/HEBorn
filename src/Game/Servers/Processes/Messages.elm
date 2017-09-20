module Game.Servers.Processes.Messages exposing (Msg(..), RequestMsg(..))

import Events.Events as Events
import Requests.Types exposing (ResponseType)
import Game.Servers.Processes.Models exposing (..)
import Game.Network.Types exposing (NIP)


type Msg
    = Pause ID
    | Resume ID
    | Remove ID
    | Start Type ServerID NIP ( Maybe FileID, Maybe Version, FileName )
    | Complete ID
    | Request RequestMsg
    | Event Events.Event


type RequestMsg
    = BruteforceRequest ID ResponseType
