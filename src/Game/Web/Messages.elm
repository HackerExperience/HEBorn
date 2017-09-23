module Game.Web.Messages exposing (Msg(..), RequestMsg(..))

import Requests.Types exposing (ResponseType)
import Game.Web.DNS exposing (Requester)


type Msg
    = Request RequestMsg
    | FetchUrl String String String Requester


type RequestMsg
    = DNSRequest String Requester ResponseType
