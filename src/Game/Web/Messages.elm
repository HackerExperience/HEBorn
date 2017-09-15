module Game.Web.Messages exposing (Msg(..), RequestMsg(..))

import Events.Events as Events
import Requests.Types exposing (ResponseType)
import Game.Web.DNS exposing (Requester)


type Msg
    = Request RequestMsg
    | Event Events.Event
    | FetchUrl String String Requester


type RequestMsg
    = DNSRequest String Requester ResponseType
