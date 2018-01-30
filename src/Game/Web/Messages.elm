module Game.Web.Messages exposing (Msg(..), RequestMsg(..))

import Requests.Types exposing (ResponseType)
import Game.Servers.Shared as Servers exposing (CId)
import Game.Meta.Types.Apps.Desktop exposing (Requester)
import Game.Meta.Types.Network as Network


type Msg
    = Request RequestMsg
    | FetchUrl String Network.ID Servers.CId Requester
    | Login Servers.CId Network.NIP Network.IP String Requester
    | JoinedServer Servers.CId
    | HandleJoinServerFailed Servers.CId


type RequestMsg
    = DNSRequest String Requester ResponseType
