module Game.Web.Messages exposing (Msg(..), RequestMsg(..))

import Events.Events as Events
import Requests.Types exposing (ResponseType)


type Msg
    = Load String
    | Refresh String
    | Request RequestMsg
    | Event Events.Event


type RequestMsg
    = DNSRequest String ResponseType
