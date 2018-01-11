module Game.Web.Messages exposing (Msg(..), RequestMsg(..))

import Requests.Types exposing (ResponseType)
import Game.Meta.Types.Requester exposing (Requester)
import Game.Servers.Shared as Servers
import Game.Web.Models exposing (..)
import Game.Meta.Types.Network as Network


type Msg
    = Request RequestMsg
    | FetchUrl String Network.ID Servers.CId Requester
    | Login Network.NIP Network.IP String Requester
    | JoinedServer Servers.CId
    | HandleJoinServerFailed Servers.CId


type RequestMsg
    = DNSRequest String Requester ResponseType
