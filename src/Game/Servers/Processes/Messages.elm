module Game.Servers.Processes.Messages exposing (Msg(..), RequestMsg(..))

import Events.Events as Events
import Requests.Types exposing (ResponseType)
import Game.Servers.Processes.Models exposing (..)
import Game.Network.Types as Network


type Msg
    = Pause ID
    | Resume ID
    | Remove ID
    | Complete ID
    | StartBruteforce Network.IP
    | StartDownload Network.IP String String
    | StartPublicDownload Network.IP String String
      -- start may be removed if we provide a specific
      -- function for every process type
    | Start Type Network.IP ( Maybe FileID, Maybe Version, FileName )
    | Request RequestMsg
    | Event Events.Event


type RequestMsg
    = BruteforceRequest ID ResponseType
    | DownloadRequest ID ResponseType
